function [px,py] = patch_dim(x,y,H,W,dfx,dfy)
    x1 = x-1;
    x2 = H-x;
    xf = min(x1,x2);
    y1 = y-1;
    y2 = W-y;
    yf = min(y1,y2);
    px = min(dfx,(2*xf+1));
    py = min(dfy,(2*yf+1));
end
