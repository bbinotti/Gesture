function kinectconnect()
%Main function for streaming gesture system

%Create objects
vid1 = videoinput('kinect', 1, 'RGB_640x480');
vid2 = videoinput('kinect', 2, 'Depth_640x480');

src2 = getselectedsource(vid2);

vid1.FrameGrabInterval = 100;
vid2.FrameGrabInterval = 100;

vid1.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;

%Crucial to save memory
triggerconfig(vid1, 'manual');
triggerconfig(vid2, 'manual');

%Kinect setting (Default RGB)
src2.DepthMode = 'Near';
src2.BodyPosture = 'Seated';

%Send data to MATLAB, but will not log frames to memory
start([vid1, vid2]);

%Setup for ending streaming by pressing a key
global KEY_PRESSED
KEY_PRESSED = 'd';
gcf; set(gcf, 'KeyPressFcn', @myKeyPressFcn);
set(gcf,'units','normalized','outerposition',[0 0 1 1]);

%initialization
prev_box = [0 0]; color = 'b'; pos = 0; fingers = [];
%load pre-computed histograms for skin detection
load('skin_histograms_small.mat');
while(KEY_PRESSED ~= 'q')
    %Get color and depth frame
    frameRGB = getsnapshot(vid1); 
    frameDepth = getsnapshot(vid2);

    subplot(2,2,1);
    imshow(frameRGB);
    
    %Segment hand
    [frameSegm,M] = handDetect(frameRGB, frameDepth, skinHist, nonSkinHist);
    
    %Display segmented hand
    subplot(2,2,2);
    imshow(frameSegm);    hold on
%     imagesc(frameSegm);    hold on

    fingers = fingerDetect(frameSegm, fingers, 5, 10, 10, 20);
    
%     %Draw bouding box of hand on color stream
%     stats = regionprops(frameSegm, 'BoundingBox', 'Centroid');
%     %Avoid crashing if failed to segment hand in one frame
%     if(isempty(stats))
%         continue
%     end
%     %Obtain and pad BB
%     box = stats.BoundingBox;
%     box(1) = box(1)-5; box(2) = box(2)-5;
%     box(3) = box(3)+(box(3)*.2); 
% %     box(4) = box(4) + (box(4)*.2);
%     box(4) = box(3);
%     subplot(2,2,1);
%     %BoundingBox position is noisy. Make it more stable
%     if(sum(abs(prev_box - [box(1),box(2)])) < 10)
%         box(1) = prev_box(1); box(2) = prev_box(2);
%     end
%     rectangle('Position',box,'EdgeColor',color,'LineWidth',2) 
%     prev_box = [box(1), box(2)];
%     hold off
%     %Pause for imshow (otherwise CPU gets overloaded)
    pause(.025)
%     
%     if( KEY_PRESSED ~= 'd' )
%         %Gesture recognition
%         [color, pos] = gestureRecognition(frameSegm, M, color, pos);
%     end
    %Clear images to guarantee memory space
%     save('data', 'frameSegm');
    clearvars frameRGB frameDepth frameSegm
    flushdata(vid1); flushdata(vid2);
%     KEY_PRESSED = 'q';
end
stop([vid1, vid2]);
close all;
%%%%%%%%
function myKeyPressFcn(hObject, event)
global KEY_PRESSED
KEY_PRESSED  = get(gcf, 'CurrentCharacter');
