function [color, pos] = gestureRecognition(frameSegm, minDepth, prev_color, prev_pos)
%Function for recognizing gesture. A hand motion is classified as a gesture
%if the hand is within a trigger depth. The start (first frame of gesture) is chosen
%when the hand moves from out to in the trigger zone (i.e. the bounding box
%color changes from blue to green). The end (last frame of gesture) is when
%the hand moves from in to out the trigger zone (i.e BB changes from green
%to blue).
%Inputs: segmented hand image (frameSegm), depth value of the hand (minDepth),
%bounding box color of the previous frame (prev_color), hand position of
%the previous frame (prev_pos).

T = 650; %depth trigger value
%if hand doing gesture (inside trigger depth)
if(minDepth < T);
    color = 'g';
    stats = regionprops(frameSegm, 'Centroid');
    centroid = stats.Centroid;
    %First point; if hand went from out to inside trigger
    if(~strcmp(prev_color, color))
        %save BoundingBox position
        pos = centroid;
    %next sequence of track
    else
        %stabilize
        if(abs(centroid(1) - prev_pos(1)) < 10)
            centroid(1) = prev_pos(1);
        end
        if(abs(centroid(2) - prev_pos(2)) < 10)
            centroid(2) = prev_pos(2);
        end
        %add new centroid to the array of gesture centroid positions
        pos = cat(1, centroid, prev_pos);
    end
%outside trigger depth
else
    color = 'b';
    %Last point of gesture; if hand went from in to out of trigger
    if(~strcmp(prev_color, color))
%         stats = regionprops(frameSegm, 'BoundingBox');
%         pos = stats.BoundingBox(1);

        %close the path and verify what gesture was done
        pos = cat(1, prev_pos, prev_pos(1,:));
        compareMasks(pos);
        pos = 0;
    else
        pos = prev_pos;
    end
end