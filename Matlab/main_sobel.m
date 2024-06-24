clear all;
close all;
clc;

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

% Loop over the detected lines and display them
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];

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
title('Detected Lines');
hold off;
