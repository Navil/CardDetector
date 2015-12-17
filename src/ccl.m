function [ labels, numLabel ] = ccl( binaryIm )
% CCL Connected component labeling in a 2D binary image for an 8-neighbourhood.
%   [LABELS, NUMLABELS] = CCL(BINARYIM) creates the new labeled image
%                           LABELS. Each identified region is succesively
%                           labeled with an integer, starting with 1. The
%                           background (i.e., black in the original image)
%                           is not taken into account for the labeling and
%                           therefore remains 0.
%



beenThere = false(size(binaryIm)); % buffer for already visited pixels
[rows, cols] = size(binaryIm);
labels = zeros(rows, cols); % the output image
numLabel = 1;

% iterate over all pixels
for row = 1 : rows
    for col = 1 : cols
        % background is ignored
        if binaryIm(row,col) == 0
            beenThere(row,col) = true;

        elseif beenThere(row,col)
            % already been there, nothing to check
            continue;

        else
            
            % make a stack on the current pixel pos
            stack = [row col];

            % depth-first floodfill labeling
            while ~isempty(stack)
                % pop from stack by taking the first row
                pos = stack(1,:);
                stack(1,:) = [];

                % skip this pixel if already been there
                if beenThere(pos(1),pos(2))
                    continue;
                end

                % been there and label
                beenThere(pos(1),pos(2)) = true;
                labels(pos(1),pos(2)) = numLabel;

                % take the 8 neighbourhood
                [locs_y, locs_x] = meshgrid(pos(2)-1:pos(2)+1, pos(1)-1:pos(1)+1);
                locs_y = locs_y(:);
                locs_x = locs_x(:);

                % delete out of bound indices
                outOfBound = locs_x < 1 | locs_x > rows | locs_y < 1 | locs_y > cols;

                locs_y(outOfBound) = [];
                locs_x(outOfBound) = [];

                % delete pixels we already been to
                is_visited = beenThere(sub2ind([rows cols], locs_x, locs_y));

                locs_y(is_visited) = [];
                locs_x(is_visited) = [];

                % delete all background pixel positions
                is_1 = binaryIm(sub2ind([rows cols], locs_x, locs_y));
                locs_y(~is_1) = [];
                locs_x(~is_1) = [];

                % the rest has to be visited and therefore stacked
                stack = [stack; [locs_x locs_y]];
            end

            % region has been labeled, increment the label couner
            numLabel = numLabel + 1;
        end
    end
 end   


end

