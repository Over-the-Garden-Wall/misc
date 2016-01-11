function solved_board = submersible(M, restrictions)

    %R(11,:,:) is water
    %R(12,:,:) is midpiece
    %R(13,:,:) is endpiece
    
    %sub is #4
    
    available_moves = find_available_moves(M, restrictions);
    
    if isnan(available_moves)
        solved_board = M;
    elseif isempty(available_moves)
        solved_board = [];
    else

        for k = 1:size(available_moves,1)
            new_M = make_move(M, available_moves(k,:));
            solved_board = submersible(new_M, restrictions);
            if ~isempty(solved_board)
                break
            end
        end
    end
    
end

function available_moves = find_available_moves(M, restrictions)
    piece_size = [4 3 3 3 2 2 2 1 1 1 1];
    
    found_piece = false;
    for k = 1:length(piece_size)
        if sum(M(k,:)) ~= piece_size(k)
            my_piece = k;
            found_piece = true;
            break
        end
    end
    if ~found_piece
        available_moves = NaN;
        return
    end
    
    sz = piece_size(my_piece);
    
        %horizonal places
        poss_starts = true(size(M,2), size(M,3));
        poss_starts(:,end-sz+1:end) = false;
        start_ind = find(poss_starts(:));
        available_moves = start_ind * ones(1,sz) + ...
            ones(length(start_ind),1) * (0:sz-1)*size(M,2);
        
        %horizonal places
        poss_starts = true(size(M,2), size(M,3));
        poss_starts(end-sz+1:end,:) = false;
        start_ind = find(poss_starts(:));
        available_moves = [available_moves; ...
            start_ind * ones(1,sz) + ...
            ones(length(start_ind),1) * (0:sz-1)];
        
        is_valid = false(size(available_moves,1),1);
        for k = 1:size(available_moves,1)
            new_M = make_move(M, [my_piece available_moves(k,:)]);
            is_valid(k) = is_valid_boardstate(new_M, restrictions);
        end
          
        available_moves = [my_piece * ones(sum(is_valid),1), available_moves(is_valid,:)];

end
    
    
function M = make_move(M, move)
    M(move(1), move(2:end)) = true;
end
       
function is_valid = is_valid_boardstate(M, restrictions)
    %check that water isn't violated
    
    T = M(:,:) & (ones(size(M,1),1) * restrictions.R(1,:));
    if any(T(:))
        is_valid = false;
        return
    end
    
    %check that pieces aren't on top of each other (other than sub)
    if any(sum(M([1:3, 5:end],:))>=2)
        is_valid = false;
        return
    end
    
    %check numbers
    %horizontal
    if any(squeeze(sum(sum(M,1),3)) > restrictions.H_nums)
        is_valid = false;
        return
    end

    %vertical
    if any(squeeze(sum(sum(M,1),2)) > restrictions.V_nums)
        is_valid = false;
        return
    end

    
    %other restrictions go here.
    
    is_valid = true;
end
            