function kinectrecord(filename)
%acquire & save kinect data
vid1 = videoinput('kinect', 1, 'RGB_640x480');
% vid2 = videoinput('kinect', 2, 'Depth_320x240');
vid2 = videoinput('kinect', 2, 'Depth_640x480');
src1 = getselectedsource(vid1);
src2 = getselectedsource(vid2);

vid1.FramesPerTrigger = 200;
vid2.FramesPerTrigger = 200;

% vid1.TriggerRepeat = 1;
% vid2.TriggerRepeat = 1;

% vid1.ReturnedColorspace = 'YCbCr';
src2.DepthMode = 'Near';
src2.BodyPosture = 'Seated';

triggerconfig([vid1, vid2], 'manual');
preview([vid1, vid2]);
pause(1);
start([vid1, vid2]);

% Trigger 200 times to get the frames.
% for i = 1:41
    % Trigger both objects.
    trigger([vid1, vid2])
    start([vid1,vid2])
    % Get the acquired frames and metadata.
    gest_color = getdata(vid1);
    gest_depth = getdata(vid2);
% end
save([filename, '_color.mat'], 'gest_color');
save([filename, '_depth.mat'], 'gest_depth');
stoppreview([vid1, vid2]);
close all hidden
