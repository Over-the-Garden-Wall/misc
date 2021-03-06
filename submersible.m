function submersible

board_num = 5;

M = false(11,10,10);
R.R = false(10,10);

if board_num == 2
    R.R(4,1) = true;
    R.R(6,[8 10]) = true;
    R.R(end,3:4) = true;
     
    R.H_nums = [1 1 3 7 0 2 3 3 0 3];
    R.V_nums = [6 0 2 3 2 2 0 4 1 3]';
    
    M(10,end,8) = true;
    
    mids = zeros(10);
    mids(4,[5 9]) = 1;
    
    R.mid_locs = find(mids(:))';
    R.end_locs = [];
elseif board_num == 3;
%     
    R.R(2,9) = true;
    R.R([3 5 7],5) = true;
    R.mid_locs = [];
    R.end_locs = [78 10];

    R.H_nums = [1 2 1 9 1 2 1 3 2 1];
    R.V_nums = [1 3 1 0 9 0 2 3 3 1]';
    
    M(7,8,8:9) = true;
elseif board_num == 4
    R.R(6,2) = true;
    
    R.mid_locs = [];
%     R.end_locs = [];
    R.end_locs = [13, 10; 70, 10];
%     M(1,end, end-3:end) = 1;
%     M(2,3, 2:4) = 1;
    


    M(8,end,3) = true;
    M(9,1,6) = true;
    M(10,5,end) = true;
    
    R.H_nums = [2 1 3 0 2 3 1 3 3 5];
    R.V_nums = [3 2 3 1 2 1 2 6 1 2]';
    
elseif board_num == 5
    
    R.R([3 5],8) = true;
    R.R(8,2) = true;
    
    R.end_locs = [15, 1];
    R.mid_locs = 55;
    
    M(8, 2, end) = true;
    
    R.H_nums = [3 1 1 1 4 2 3 1 6 1];
    R.V_nums = [2 4 1 3 1 4 4 2 0 2]';
    
    
end
M = finish_board(M,R);
%     

end


function solved_board = finish_board(M, restrictions)

    %R(11,:,:) is water
    %R(12,:,:) is midpiece
    %R(13,:,:) is endpiece
    
    %sub is #4
    
    available_moves = find_available_moves(M, restrictions);
    
    
    
    if isnan(available_moves)
        solved_board = M;
    elseif isempty(available_moves)
        solved_board = [];
    elseif available_moves(1,1) > 3 && ~mids_are_used(M, restrictions)
        solved_board = [];
    elseif available_moves(1,1) > 7 && ~ends_are_used(M, restrictions)
        solved_board = [];
        
    else
        

        for k = 1:size(available_moves,1)
            new_M = make_move(M, available_moves(k,:));
            solved_board = finish_board(new_M, restrictions);
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
        poss_starts(:,end-sz+2:end) = false;
        start_ind = find(poss_starts(:));
        available_moves = start_ind * ones(1,sz) + ...
            ones(length(start_ind),1) * (0:sz-1)*size(M,2);
        
        %horizonal places
        poss_starts = true(size(M,2), size(M,3));
        poss_starts(end-sz+2:end,:) = false;
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
    
    T = M([1:3 5:end],:) & (ones(size(M,1)-1,1) * restrictions.R(:)');
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

    %check midsegments
    for k = restrictions.mid_locs
        piece_num = find(M(:,k),1, 'first');
        if ~isempty(piece_num)
            if piece_num > 3
                is_valid = false;
                return
            end
            if ~(M(piece_num,k-1) && M(piece_num, k+1)) && ...
                ~(M(piece_num,k-10) && M(piece_num, k+10))
                is_valid = false;
                return
            end
        end
    end
    
    %check ends
    for k = 1:size(restrictions.end_locs,1)
        RE = restrictions.end_locs(k,:);
        piece_num = find(M(:,RE(1)),1, 'first');
        if ~isempty(piece_num)
            if piece_num == 4 || piece_num >= 8
                is_valid = false;
                return
            end
            if ~M(piece_num,RE(1)+RE(2)) || M(piece_num,RE(1)-RE(2))
                is_valid = false;
                return
            end
        end
    end        
    
    %other restrictions go here.
    
    is_valid = true;
end


function is_used = mids_are_used(M, restrictions)
    is_used = true;
    for k = restrictions.mid_locs
        if ~any(M(:,k))
            is_used = false;
        end
    end

end

function is_used = ends_are_used(M, restrictions)
    is_used = true;
    for k = 1:size(restrictions.end_locs,1)
        if ~any(M(:,restrictions.end_locs(k,1)))
            is_used = false;
        end
    end

end
                   