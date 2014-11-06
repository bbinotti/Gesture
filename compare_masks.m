function compare_masks(pos)
%Input: gesture centroid positions array
mask_files = ls('./masks');
compare = zeros(size(mask_files,1) - 2, 1);

%create mask from position array
path = poly2mask(pos(:,1),pos(:,2),240,320);
%remove any tails
path = bwmorph(path, 'open');
cc = bwconncomp(path);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);
for k = 1 : cc.NumObjects
    if(k ~= idx)
        path(cc.PixelIdxList{k}) = 0;
    end
end

%easier to center padded mask
path = padarray(path, [200,200]);
stats_path = regionprops(path, 'Area', 'BoundingBox', 'Centroid');
%center path mask 320x240
path = path( stats_path.Centroid(2)-120:stats_path.Centroid(2)+119,...
        stats_path.Centroid(1)-160:stats_path.Centroid(1)+159 );
% figure; imshow(path);
subplot(2,2,3);
imshow(path);
assignin('base','path',path);
for i = 3 : size(mask_files,1)
    %load true mask
    load(['./masks/', mask_files(i,:)]); %variable name: mask
    %stretch true mask according to path mask
    prop = (stats_path.BoundingBox(3)/stats_path.BoundingBox(4));
    mask = imresize(mask, 'Scale', [1, prop] );
    %make both areas equal
    stats_mask = regionprops(mask, 'Area');
    alpha = sqrt(stats_path.Area/stats_mask.Area);
    mask = imresize(mask, alpha);
    %Center and pad
    if(size(mask,1) > 240 || size(mask,2) > 320)
        %crop
        mask = padarray(mask, [200,200]);
        stats_mask = regionprops(mask, 'Area','Centroid');
        mask = mask( stats_mask.Centroid(2)-120:stats_mask.Centroid(2)+119,...
            stats_mask.Centroid(1)-160:stats_mask.Centroid(1)+159 );
    else
        %pad
        mask = padarray(mask, [floor((240-size(mask,1))/2), floor((320-size(mask,2))/2)], 'pre' );
        mask = padarray(mask, [(240-size(mask,1)), (320-size(mask,2))], 'post' );
    end
%     figure, imshow(mask);
%     figure, imshow(path .* mask);
    test1 = path .* mask;
    test2 = regionprops(test1, 'Area');
    compare(i-2) = test2.Area/(stats_path.Area);
end
temp = max(compare);
shape = find(compare==temp);
load(['./masks/', mask_files(shape+2,:)]);
subplot(2,2,4);
imshow(mask);

