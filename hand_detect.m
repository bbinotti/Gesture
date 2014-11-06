function [x, closest] = hand_detect(gest_color, gest_depth)
% Segment hand using depth and color images (frame)
% Inputs: YCbCr image (gest_color), corresponding depth image (gest_depth)
% Outputs: segmented hand image (x), distance value of closest point to
% device (closest)

%Depth segmentation
y = double(gest_depth);

%Kinect maps undetected depth values to zero. Set those to NaN
y(y==0) = nan;

%Normalize if probabilistic measure is wanted
% y = y ./ max(max(y));

closest = min(min(y));
[i,j] = find(y==closest);

y = y < closest+120;

%YCbCr color segmentation
Cb = double(gest_color(:,:,2,1));
% CbM = 255;
% Cb = Cb ./ CbM;

Cr = double((gest_color(:,:,3,1)));
% CrM = 255;
% Cr = Cr ./ CrM;

%segm
c = Cb < 135 & Cb > 120;
d = Cr < 155 & Cr > 130;

% x = y.*c.*d;
x = y.*d;
% x = y;
x = medfilt2(x, [3 3]);

%Keep largest blob
cc = bwconncomp(x);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);

% high = 0;
% for i = 1 : length(stats)
%     if(stats.Centroid(i) > high)
%         high = stats.Centroid(i);
%         k = i; %keep index
%     end
% end

for i = 1 : cc.NumObjects
    if(i ~= idx)
        x(cc.PixelIdxList{i}) = 0;
    end
end
if(biggest < 100)
    x(:) = 0;
end
%Make bound square
x = x(:,1:240);