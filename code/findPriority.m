function [pix_x, pix_y,conf_level] = findPriority(b,mask,conf_mat, D)
num_of_boundary_pts = size(b, 1);

max_conf = -1;
max_prior = -1;
pix_ctr_x = -1;
pix_ctr_y = -1;

H = size(conf_mat, 1);
W = size(conf_mat, 2);

for i = 1:num_of_boundary_pts
   cur_x = b(i, 1);
   cur_y = b(i, 2);
   [px, py] = patch_dim(cur_x, cur_y, H, W, 9, 9);
  
   cur_conf = 0;
   for l = ceil(-px/2):floor(px/2)
      for m = ceil(-py/2):floor(py/2)
           x = cur_x + l;
           y = cur_y + m;
           if mask(int32(x), int32(y)) == 0
                cur_conf = cur_conf + conf_mat(int32(x), int32(y));
           end
      end
   end
  
   Cp = double(cur_conf) / double(px * py);
   Dp = D(i);
  
   if Cp * Dp > max_prior
       max_prior = Cp * Dp;
       pix_ctr_x = cur_x;
       pix_ctr_y = cur_y;
       max_conf = Cp;
   end
end

pix_x = pix_ctr_x;
pix_y = pix_ctr_y;
conf_level = max_conf;

end
