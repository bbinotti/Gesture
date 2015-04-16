function frameMask = skinClassifier(frameRGB, skinHist, nonSkinHist)

nSkin = sum(sum(skinHist));
nNonSkin = sum(sum(nonSkinHist));
bins = size(skinHist,1) - 1;

% skinHist = skinHist / nSkin;
% nonSkinHist = nonSkinHist / nNonSkin;

frameRGB = im2double(frameRGB);
frameYCbCr = rgb2ycbcr(frameRGB);
%normalize
frameYCbCr(:,:,2:3) = (frameYCbCr(:,:,2:3) - (16/255)) / ((240/255) - (16/255));
subplot(2,2,4), imagesc(frameYCbCr);
% T = nNonSkin / nSkin; %[0,1]

frameMask = zeros(size(frameYCbCr,1), size(frameYCbCr,2));
for i = 1 : size(frameYCbCr, 1)
    for j = 1 : size(frameYCbCr,2)
        Cb = floor(frameYCbCr(i,j,2) * bins) + 1; %index
        Cr = floor(frameYCbCr(i,j,3) * bins) + 1;;
        L = (skinHist(Cb,Cr) * nSkin) / (nonSkinHist(Cb,Cr) * nNonSkin);
        if( isnan(L) || isinf(L))
            L = 0;
        end
        frameMask(i,j) = L;
    end
end
frameMask( frameMask > (20 * std2(frameMask)) ) = 0; %remove beyond extreme responses
frameMask = frameMask ./ max(max(frameMask));
frameMask = frameMask > 0.2;
% figure, imagesc(frameMask);