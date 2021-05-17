function [q_x,q_y] = findSimilarPatch(px, py, bx, by, img, conf_mat)
    % findSimilarPatch: find a patch Q in the known region in img with 
    % minimum euclidean distance from the patch P of dimensions (px, py)
    % centered at (bx, by)

H = size(img, 1);     % height of input image
W = size(img, 2);     % width of input image

% coordinate of center of patch with min. distance from given patch
% of dimension (px, py)
qx = -1;
qy = -1;
min_dist = 9999999;

for i = 1:H
    for j = 1:W
        % consider patch (i, j) as center of potential Q
        % first check if this Q lies completely in the image
        if i - floor(px/2) <= 0 || i + floor(px/2) > H
            continue;
        elseif j - floor(py/2) <= 0 || j + floor(py/2) > W
            continue;
        end
        
        % now check if the patch lies completely in the known region
        % i.e. the confidence of all pixels in the patch > 0
        
        valid = true;
        
        for x = i-floor(px/2):i+floor(px/2)
            for y = j-floor(py/2):j+floor(py/2)
                if conf_mat(int32(x),int32(y)) == 0.0
                    valid = false;
                    break
                end
            end
        end
        
        % if this patch is not valid, move to next
        if valid == false
            continue;
        end
        
        % compute the distance of this patch from the input patch
        dist = 0;
        
        for x = ceil(-px/2):floor(px/2)
            for y = ceil(-py/2):floor(py/2)
                pix_p = img(int32(bx+x), int32(by+y));
                pix_q = img(int32(i+x), int32(j+y));
                  if conf_mat(int32(bx+x), int32(by+y)) > 0 
                       dist = dist + findDistance(pix_p, pix_q);
                       %fprintf("  Center: [%d, %d],  dist --> %f\n", i, j, dist);
                  end
            end
        end
        
        % if the current distance is less than min distance so far
        % select this patch as the answer
        dist = sqrt(dist);
        if dist < min_dist
            min_dist = dist;
            qx = i;
            qy = j;
            %fprintf("The chosen patch is updated, new center = [%d, %d]\n with min_dist = %f", qx, qy, min_dist);

        end
    end
end

% return (qx, qy)
q_x = int32(qx);
q_y = int32(qy);

end