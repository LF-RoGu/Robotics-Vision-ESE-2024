clear all;
close all;
clc;

% Read the image
img = imread('data/image_left_unrect/image_left_unrect_143.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Save the grayscale image
% imwrite(gray_img, 'gray_image.png');

% Apply Gaussian filter
N = 3; % Kernel size
gauss_img = ifilter_gauss(gray_img, N);

% Define the region of interest (ROI)
% Examples:
% [x, y, width, height]
roi = [700, 0, 600, 800]; % Specific area

% Apply Harris filter within the ROI
nfeat = 100; % Number of features to extract
[v, u, s, corner_strength] = iharris_roi(gauss_img, nfeat, roi);

% Plot the Harris corners on the original grayscale image
figure, imshow(gray_img); hold on;
plot(u, v, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
hold off;

% Print coordinates of detected points
%disp('Coordinates of strong points:');
coords_table = table(u, v);
%disp(coords_table);

% Calculate distances between points and retain only those points that are close to each other
max_distance = 1;
close_points = [];

for i = 1:length(u)
    for j = i+1:length(u)
        distance = sqrt((u(i) - u(j))^2 + (v(i) - v(j))^2);
        if (distance <= max_distance)
            close_points = [close_points; u(i), v(i); u(j), v(j)];
            %fprintf('Distance closer than %d units.\n', max_distance);
            fprintf('Points: (%d, %d) and (%d, %d), Distance: %.2f\n', u(i), v(i), u(j), v(j), distance);
        else
            %fprintf('Distance greater than %d units.\n', max_distance);
            %fprintf('Points: (%d, %d) and (%d, %d), Distance: %.2f\n', u(i), v(i), u(j), v(j), distance);
        end
    end
end

% Remove duplicate points
close_points = unique(close_points, 'rows');

% Print and save coordinates of close points
%disp('Coordinates of close points (within 10 units):');
close_points_table = array2table(close_points, 'VariableNames', {'u', 'v'});
%disp(close_points_table);

% Plot the close points on the original grayscale image
figure, imshow(gray_img); hold on;
plot(close_points(:, 1), close_points(:, 2), 'c+', 'MarkerSize', 5, 'LineWidth', 1);
hold off;