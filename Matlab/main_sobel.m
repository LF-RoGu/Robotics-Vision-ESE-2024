clear all;
close all;
clc;

% Define the ROI [x, y, width, height]
roi = [700, 200, 600, 500];

% Read the image
img = imread('data/image_left_unrect/image_left_unrect_143.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Apply the Sobel filter
[kernel_u, kernel_v] = ifilter_sobel(gray_img);

subplot(1, 2, 1);
imagesc(kernel_u);
axis image; % Keep the aspect ratio of the image
colormap gray; % Use grayscale colormap
title('Horizontal Edges');

subplot(1, 2, 2);
imagesc(kernel_v);
axis image; % Keep the aspect ratio of the image
colormap gray; % Use grayscale colormap
title('Vertical Edges');

% Combine the horizontal and vertical edges
edge_img = sqrt(kernel_u.^2 + kernel_v.^2);

% Apply a threshold to get a binary edge image
threshold = 60; % You can adjust this threshold value
binary_edge_img = edge_img > threshold;

% Focus on the center part of the image
[rows, cols] = size(binary_edge_img);
margin = 10; % Define the margin size to be excluded from the edges
binary_edge_img(1:margin, :) = 0; % Top margin
binary_edge_img(rows-margin+1:end, :) = 0; % Bottom margin
binary_edge_img(:, 1:margin) = 0; % Left margin
binary_edge_img(:, cols-margin+1:end) = 0; % Right margin

% Perform Hough Transform to detect lines
[H, T, R] = hough(binary_edge_img);

% Find peaks in the Hough Transform matrix
P = houghpeaks(H, 5, 'threshold', ceil(0.3*max(H(:))));

% Extract lines based on the Hough Transform
lines = houghlines(binary_edge_img, T, R, P, 'FillGap', 20, 'MinLength', 40);

% Display the original image with detected lines
figure;
imshow(img);
hold on;

% Initialize an array to store line features
line_features = [];

% Loop over the detected lines and display them if they are within the ROI
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];

    % Check if the line falls within the ROI
    if all(xy(:,1) >= roi(1) & xy(:,1) <= roi(1) + roi(3) & ...
           xy(:,2) >= roi(2) & xy(:,2) <= roi(2) + roi(4))

        % Plot beginnings and ends of lines
        plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
        plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');

        % Extract line features: length and angle
        len = norm(lines(k).point1 - lines(k).point2);
        theta = atan2((lines(k).point2(2) - lines(k).point1(2)), (lines(k).point2(1) - lines(k).point1(1))) * 180 / pi;

        % Print the coordinates of the points
        fprintf('Line %d: Point 1 (X, Y) = (%.2f, %.2f), Point 2 (X, Y) = (%.2f, %.2f), Angle = %.2f degrees\n', ...
            k, xy(1,1), xy(1,2), xy(2,1), xy(2,2), theta);

        % Set color based on angle
        if theta < 0
            plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
        else
            plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
        end

        % Store the features
        line_features = [line_features; len, theta];
    end
end
title('Detected Lines within ROI');
hold off;

% Find intersections between lines within the ROI
intersection_points = [];
for i = 1:length(lines)
    for j = i+1:length(lines)
        % Line 1 points
        x1 = lines(i).point1(1);
        y1 = lines(i).point1(2);
        x2 = lines(i).point2(1);
        y2 = lines(i).point2(2);
        
        % Line 2 points
        x3 = lines(j).point1(1);
        y3 = lines(j).point1(2);
        x4 = lines(j).point2(1);
        y4 = lines(j).point2(2);
        
        % Check if both lines are within the ROI
        if all([x1, x2] >= roi(1) & [x1, x2] <= roi(1) + roi(3) & ...
               [y1, y2] >= roi(2) & [y1, y2] <= roi(2) + roi(4)) && ...
           all([x3, x4] >= roi(1) & [x3, x4] <= roi(1) + roi(3) & ...
               [y3, y4] >= roi(2) & [y3, y4] <= roi(2) + roi(4))
        
            % Solve for intersection
            denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
            if denom ~= 0
                Px = ((x1*y2 - y1*x2) * (x3 - x4) - (x1 - x2) * (x3*y4 - y3*x4)) / denom;
                Py = ((x1*y2 - y1*x2) * (y3 - y4) - (y1 - y2) * (x3*y4 - y3*x4)) / denom;
                
                % Check if the intersection point is within the line segments
                if (min(x1,x2) <= Px && Px <= max(x1,x2)) && (min(y1,y2) <= Py && Py <= max(y1,y2)) && ...
                   (min(x3,x4) <= Px && Px <= max(x3,x4)) && (min(y3,y4) <= Py && Py <= max(y3,y4))
                    intersection_points = [intersection_points; Px, Py];
                    fprintf('Intersection of Line %d and Line %d: (X, Y) = (%.2f, %.2f)\n', i, j, Px, Py);
                end
            end
        end
    end
end

% Display intersection points
figure;
imshow(img);
hold on;
plot(intersection_points(:,1), intersection_points(:,2), 'ro', 'MarkerSize', 10);
title('Intersection Points within ROI');
hold off;
