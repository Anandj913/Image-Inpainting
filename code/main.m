clc; 
clear; 
close all; 
imtool close all;  
workspace;  

fontSize = 8;
imgfile = "hockey.png";
dpx = 9;
dpy = 9;


Image = imread(imgfile);
imshow(Image);
axis on;
title('Original Image', 'FontSize', fontSize);
set(gcf, 'Position', get(0,'Screensize')); 
message = sprintf('Select the region you want to remove from image.\n\nTo select: Left click and hold to begin drawing.\nSimply lift the mouse button to finish.\n\nPress OK to start');
uiwait(msgbox(message));
hFH = imfreehand();
mask = hFH.createMask();

Image = double(Image);
imgsize = size(Image);
bsize = size(mask);
mask_removed_image = Image.*repmat(~mask, [1,1,3]);
imshow(mask_removed_image/255);

axis on;
title('Mask removed image', 'FontSize', fontSize);

%%algo 
C = double( ~mask);
D = [];

[Ix(:,:,3), Iy(:,:,3)] = gradient(mask_removed_image(:,:,3));
[Ix(:,:,2), Iy(:,:,2)] = gradient(mask_removed_image(:,:,2));
[Ix(:,:,1), Iy(:,:,1)] = gradient(mask_removed_image(:,:,1));
Ix = sum(Ix,3)/(3*255); Iy = sum(Iy,3)/(3*255);
    
temp = Ix; Ix = -Iy; Iy = temp; 

while(sum(mask(:)) ~= 0)
    boundary = bwboundaries(mask);
    bp = boundary{1};
    for i=2:size(boundary,1)
        b = boundary{i};
        bp =  vertcat(bp, b);
    end
    
    Ipx = zeros(size(bp,1), 1);
    Ipy = zeros(size(bp,1), 1);
    for k = 1:size(bp, 1)
        Ipx(k) = Ix(int32(bp(k,1)),int32(bp(k,2)));
        Ipy(k) = Iy(int32(bp(k,1)),int32(bp(k,2)));
    end
    N = LineNormals2D(bp);
    N(~isfinite(N))=0;
    
    D = double(abs(Ipx.*N(:,1) + Ipy.*N(:,2)))/255;
    
    
    lab = rgb2lab(mask_removed_image);
    
    [bx, by, max_priority_C] = findPriority(bp, mask, C, D);
    
    [px, py] = patch_dim(bx, by, size(Image,1), size(Image,2), dpx, dpy);
    
    [mx, my] = findSimilarPatch(px, py, bx, by, lab, ~mask);
    
    %update_image
    for x = ceil(-px/2):floor(px/2)
        for y = ceil(-py/2):floor(py/2)
            source_r = mask_removed_image(int32(mx+x), int32(my+y), 1); 
            source_g = mask_removed_image(int32(mx+x), int32(my+y), 2);   
            source_b = mask_removed_image(int32(mx+x), int32(my+y), 3);   

            if C(int32(bx+x), int32(by+y)) <= 0 
              mask_removed_image(int32(bx+x), int32(by+y), 1) = source_r;
              mask_removed_image(int32(bx+x), int32(by+y), 2) = source_g;
              mask_removed_image(int32(bx+x), int32(by+y), 3) = source_b;
              
              Ix(int32(bx+x), int32(by+y)) = Ix(int32(mx+x), int32(my+y));
              Iy(int32(bx+x), int32(by+y)) = Iy(int32(mx+x), int32(my+y));
            end
        end
    end
    
    %update_C matrix
    for x = ceil(-px/2):floor(px/2)
        for y = ceil(-py/2):floor(py/2)  
            if mask(int32(bx+x), int32(by+y)) == 1 
              C(int32(bx+x), int32(by+y)) = max_priority_C;
            end
        end
    end
    
    %update_mask
    for x = ceil(-px/2):floor(px/2)
        for y = ceil(-py/2):floor(py/2)
            mask(int32(bx+x), int32(by+y)) = 0.0;
        end
    end
    imshow(mask_removed_image/255);
    fprintf("Number of pixels left in mask: %d\n", sum(mask(:)));
end
imshow(mask_removed_image/255);

