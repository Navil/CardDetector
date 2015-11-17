function [ labels, numLabel ] = ccl( binaryIm, neighbourhood )
% CCL Labels connectec components in a 2D binary image.
%   [LABELS, NUMLABELS] = CCL(BINARYIM) creates the new labeled image
%                           LABELS. Each identified region is succesively
%                           labeled with an integer, starting with 1. The
%                           background (i.e., black in the original image)
%                           is not taken into account for the labeling and
%                           therefore remains 0.
%
%   [LABELS, NUMLABELS] = CCL(BINARYIM, 4) does the same as
%                           mentioned above, but in the given
%                           neighbourhood. The default is 8-connected,
%                           option is 4-connected.


beenThere = false(size(binaryIm));
[rows, cols] = size(binaryIm);
labels = zeros(rows, cols);
numLabel = 1;


for row = 1 : rows
    for col = 1 : cols
        % background is ignored
        if binaryIm(row,col) == 0
            beenThere(row,col) = true;

        elseif beenThere(row,col)
            % already been there, nothing to check
            continue;

        else
            % initialize a stack on this position
            stack = [row col];

            % and go depth-first
            while ~isempty(stack)
                % pop the first element
                pos = stack(1,:);
                stack(1,:) = [];

                %// If we have visited this location, continue
                if beenThere(pos(1),pos(2))
                    continue;
                end

                %// Mark location as true and mark this location to be
                %// its unique ID
                beenThere(pos(1),pos(2)) = true;
                labels(pos(1),pos(2)) = numLabel;

                %// Look at the 8 neighbouring locations
                [locs_y, locs_x] = meshgrid(pos(2)-1:pos(2)+1, pos(1)-1:pos(1)+1);
                locs_y = locs_y(:);
                locs_x = locs_x(:);

                %// Get rid of those locations out of bounds
                out_of_bounds = locs_x < 1 | locs_x > rows | locs_y < 1 | locs_y > cols;

                locs_y(out_of_bounds) = [];
                locs_x(out_of_bounds) = [];

                %// Get rid of those locations already visited
                is_visited = beenThere(sub2ind([rows cols], locs_x, locs_y));

                locs_y(is_visited) = [];
                locs_x(is_visited) = [];

                %// Get rid of those locations that are zero.
                is_1 = binaryIm(sub2ind([rows cols], locs_x, locs_y));
                locs_y(~is_1) = [];
                locs_x(~is_1) = [];

                %// Add remaining locations to the stack
                stack = [stack; [locs_x locs_y]];
            end

            %// Increment counter once complete region has been examined
            numLabel = numLabel + 1;
        end
    end
 end   


end

