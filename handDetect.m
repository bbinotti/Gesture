function [frameSegm, minDepth] = handDetect(frameRGB, frameDepth, skinHist, nonSkinHist)
% Segment hand using depth and color images (frame)
% Inputs: RGB image (frameRGB), corresponding depth image (frameDepth)
% Outputs: segmented hand image (frameSegm), distance value of minDepth point to
% device (minDepth)

frameSkinProb = skinClassifier(frameRGB, skinHist, nonSkinHist);
subplot(2,2,3), imagesc(frameSkinProb);

%Depth segmentation
frameDepthNaN = double(frameDepth);

%Kinect maps undetected depth values to zero. Set those to NaN
frameDepthNaN(frameDepthNaN == 0) = nan;

%Normalize [0,1]
% frameDepthNaN = frameDepthNaN ./ maframeSegm(maframeSegm(frameDepthNaN));

frameSegm = frameDepthNaN .* frameSkinProb; %use minDepth prob points
subplot(2,2,4), imagesc(frameSegm);
frameSegm(frameSegm == 0) = nan;
p = min(min(frameSegm));
[i,j] = find(frameSegm == p);
minDepth = frameDepthNaN(i(1),j(1));

%Detect hand at several levels (should do some overlapping)
% frameDepthNaN = floor(frameDepthNaN / 200); 
% frameDepthNaN = frameDepthNaN - min(min(frameDepthNaN-1)); %level indices [1,L]

% L = max(max(frameSegm));
% handflag = 0;
% for level = minDepth : 200 : L
% %     figure, imagesc(frameDepthNaN == level);
% %     title(num2str(level));
%     if(handflag)
%         subplot(2,2,4), imagesc(frameDepthNaN < (level + 120));
%         title(num2str(level));
%         break;
%     else
%         handflag = 1;
%         subplot(2,2,3), imagesc(frameDepthNaN < (level + 120));
%         title(num2str(level));
%     end
% end

% frameDepthNaN = frameDepthNaN < minDepth+120;
frameSegm = frameDepthNaN < (minDepth + 80);

%Keep largest blob
cc = bwconncomp(frameSegm);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);

%keep highest segmentation (start from max height?)
% high = 0;
% for i = 1 : length(stats)
%     if(stats.Centroid(i) > high)
%         high = stats.Centroid(i);
%         k = i; %keep index
%     end
% end

% if(biggest < 100)
%     frameSegm(:) = 0;
% end
% %Make bound square
% frameSegm = frameSegm(:,1:240);