function kinectconnect()
%Main function for streaming gesture system

%Create objects
vid1 = videoinput('kinect', 1, 'RGB_640x480');
vid2 = videoinput('kinect', 2, 'Depth_320x240');

src2 = getselectedsource(vid2);

vid1.FrameGrabInterval = 100;
vid2.FrameGrabInterval = 100;

vid1.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;

%Crucial to save memory
triggerconfig(vid1, 'manual');
triggerconfig(vid2, 'manual');

%Kinect setting (Default RGB)
% vid1.ReturnedColorspace = 'YCbCr';
src2.DepthMode = 'Near';
src2.BodyPosture = 'Seated';

%Send data to MATLAB, but will not log frames to memory
start([vid1, vid2]);

%Setup for ending streaming by pressing a key
global KEY_PRESSED
KEY_PRESSED = 0;
gcf; set(gcf, 'KeyPressFcn', @myKeyPressFcn);

figure, set(gcf,'units','normalized','outerposition',[0 0 1 1]);
%Initialization
prev_box = [0 0]; color = 'b'; pos = 0;
while(~KEY_PRESSED)
    %Get color and depth frame
    gest_color = getsnapshot(vid1); 
    gest_color = imresize(gest_color,.5);
    gest_depth = getsnapshot(vid2);
    
    %Display raw color stream and segmented hand
    subplot(2,2,1);
    imshow(gest_color);
    
    %RGB to YCbCr
    gest_color = rgb2ycbcr(gest_color);
    
    %Segment hand
    [x,M] = hand_detect(gest_color, gest_depth);
    
    %Display segmented hand
    subplot(2,2,2);
    imshow(x);    hold on
    %Draw bouding box of hand on color stream
    stats = regionprops(x, 'BoundingBox', 'Centroid');
    %Avoid crashing if failed to segment hand in one frame
    if(isempty(stats))
        continue
    end
    %Obtain and pad BB
    box = stats.BoundingBox;
    box(1) = box(1)-5; box(2) = box(2)-5;
    box(3) = box(3)+(box(3)*.2); 
%     box(4) = box(4) + (box(4)*.2);
    box(4) = box(3);
    subplot(2,2,1);
    %BoundingBox position is noisy. Make it more stable
    if(sum(abs(prev_box - [box(1),box(2)])) < 10)
        box(1) = prev_box(1); box(2) = prev_box(2);
    end
    rectangle('Position',box,'EdgeColor',color,'LineWidth',2) 
    prev_box = [box(1), box(2)];
    hold off
    %Pause for imshow (otherwise CPU gets overloaded)
    pause(.025)
    
    %Gesture recognition
    [color, pos] = gesture_recognition(x, M, color, pos);
    
    %Clear images to guarantee memory space
    clearvars gest_color gest_depth x
    flushdata(vid1); flushdata(vid2);
end
stop([vid1, vid2]);
%%%%%%%%
function myKeyPressFcn(hObject, event)
global KEY_PRESSED
KEY_PRESSED  = 1;