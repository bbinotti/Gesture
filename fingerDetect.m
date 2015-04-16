function fingers = fingerDetect(im, prev_fingers, nFingers, smoothSTD, smoothSize, windowSize)
%returns #nFingers fingers of image (im). std dev smoothing
%kernel (smoothSTD) and size of smoothing window(windowSize)

% im = imresize(dino01, .1);
if( size(im, 3) > 1)
    im = rgb2gray(im);
end
if( islogical(im) )
    im = im2double(im);
end
h = fspecial('gaussian', smoothSize, smoothSTD);
im_s = imfilter(im, h, 'same');

kernel = 1/12 * [-1, 8, 0, -8, 1];
Fx = conv2(im_s, kernel, 'same');
Fy = conv2(im_s, kernel', 'same');

if( ~isempty(prev_fingers) )
    window = ones(windowSize, windowSize);
    %compute elements of C
    Cxx = conv2(Fx.^2, window, 'same');
    Cyy = conv2(Fy.^2, window, 'same');
    Cxy = conv2(Fx.*Fy, window, 'same');
    
    %compute eigenvalues
    temp1 = (Cxx + Cyy);
    temp2 = (Cxx.^2+Cyy.^2 - 2*(Cxx.*Cyy)+4*(Cxy).^2).^(1/2);
    temp2 = real(temp2); % Get rid of small imaginary components
    e = min(temp1+temp2,temp1-temp2)/2;
    
    %eliminate corner responses from convolution and smoothing
    A = zeros(windowSize+smoothSize , windowSize+smoothSize);
    e( 1 : windowSize+smoothSize , 1 : windowSize+smoothSize ) = A;
    e( 1 : windowSize+smoothSize , end - windowSize-smoothSize+1 : end ) = A;
    e( end - windowSize-smoothSize+1 : end , 1 : windowSize+smoothSize ) = A;
    e( end - windowSize-smoothSize+1 : end, end - windowSize-smoothSize+1 : end ) = A;
    
    %nonMaximumSupression
    e = nonMaxSupr(e);
    e_sort = sort(unique(e(:)), 'descend');
    
    %keep #nFingers strongest responses
    fingers = zeros(nFingers, 2);
    j = 1; l = 1;
    % figure, imshow(im); hold on;
    while (j <= nFingers)
        [m_corner, n_corner] = find(e == e_sort(l));
        %if more than one corner matches
        for k = 1 : size(m_corner)
            fingers(j,:) = [m_corner(k), n_corner(k)];
            try
                patch = (im( fingers(j,1) - 20 : fingers(j,1) + 20, fingers(j,2) - 20 : fingers(j,2) + 20 ));
            catch
                return;
            end
            %         figure, imshow(patch);
            %         title(num2str( sum(sum(patch)) ));
            if( sum(sum(patch)) > 1000 )
                %             disp( sum(sum(patch)) );
                continue;
            end
            
            j = j + 1;
        end
        l = l + 1;
    end
    if( nFingers > size(prev_fingers,1))
        %fingers have changed, plot new ones
    else
        for j = 1 : nFingers
            %Check if fingers are close
            diff = fingers(j,:) - prev_fingers(j,:);
            diff = sum(sum( diff.^2 ));
            if( diff > 10 && diff < 3 )
                fingers(j,:) = prev_fingers(j,:);
                disp('big ol jump');
            end
        end
        for j = 1 : nFingers
            plot(fingers(j,2), fingers(j,1), 'bo', 'MarkerSize', 16, 'LineWidth', 2);
        end
    end
    
    hold off;
else
    fingers_p = prev_fingers;
    for W = floor(windowSize / 2) : 5 : windowSize * 2
        windowSize = W;
        window = ones(windowSize, windowSize);
        %compute elements of C
        Cxx = conv2(Fx.^2, window, 'same');
        Cyy = conv2(Fy.^2, window, 'same');
        Cxy = conv2(Fx.*Fy, window, 'same');
        
        %compute eigenvalues
        temp1 = (Cxx + Cyy);
        temp2 = (Cxx.^2+Cyy.^2 - 2*(Cxx.*Cyy)+4*(Cxy).^2).^(1/2);
        temp2 = real(temp2); % Get rid of small imaginary components
        e = min(temp1+temp2,temp1-temp2)/2;
        
        %eliminate corner responses from convolution and smoothing
        A = zeros(windowSize+smoothSize , windowSize+smoothSize);
        e( 1 : windowSize+smoothSize , 1 : windowSize+smoothSize ) = A;
        e( 1 : windowSize+smoothSize , end - windowSize-smoothSize+1 : end ) = A;
        e( end - windowSize-smoothSize+1 : end , 1 : windowSize+smoothSize ) = A;
        e( end - windowSize-smoothSize+1 : end, end - windowSize-smoothSize+1 : end ) = A;
        
        %nonMaximumSupression
        e = nonMaxSupr(e);
        e_sort = sort(unique(e(:)), 'descend');
        
        %keep #nFingers strongest responses
        fingers = zeros(nFingers, 2);
        j = 1; l = 1;
        % figure, imshow(im); hold on;
        while (j <= nFingers)
            [m_corner, n_corner] = find(e == e_sort(l));
            %if more than one corner matches
            for k = 1 : size(m_corner)
                fingers(j,:) = [m_corner(k), n_corner(k)];
                try
                    patch = (im( fingers(j,1) - 20 : fingers(j,1) + 20, fingers(j,2) - 20 : fingers(j,2) + 20 ));
                catch
                    return;
                end
                if( sum(sum(patch)) > 1000 )
                    continue;
                end
                j = j + 1;
            end
            l = l + 1;
        end
        fingers_p = cat(3, fingers_p, fingers);
    end
    
    fingers = zeros(nFingers, 2);
    for j = 1 : nFingers
        temp = zeros(size(fingers_p,3),2);
        for l = 1 : size(fingers_p,3)
            temp(l,:) = fingers_p(j,:,l);
        end
        fingers(j,1) = median( temp(:,1) );
        fingers(j,2) = median( temp(:,2) );
        plot(fingers(j,2), fingers(j,1), 'bo', 'MarkerSize', 16, 'LineWidth', 2);
    end
    hold off;
end