clear all;
close all;
clc;
% Read the image
img = imread('image_left_unrect_0.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Save the grayscale image
imwrite(gray_img, 'gray_image.png');

% Apply Gaussian filter
N = 3; % Kernel size
gauss_img = ifilter_gauss(gray_img, N);

% Save the Gaussian filtered image
imwrite(uint8(gauss_img), 'gaussian_filtered_image.png');

% Define the region of interest (ROI)
% Examples:
% [x, y, width, height]
% roi = [100, 100, 200, 200]; % Central region
roi = [700, 200, 700, 500]; % Specific area
% roi = [0, size(gray_img, 1) - 600, size(gray_img, 2), 100]; % Entire width, specific height
% roi = [size(gray_img, 2) - 600, size(gray_img, 1) - 600, size(gray_img, 2), 100]; % Bottom right corner

% Apply Harris filter within the ROI
nfeat = 100; % Number of features to extract
[v, u, s, corner_strength] = iharris_roi(gauss_img, nfeat, roi);

% Plot the Harris corners on the original grayscale image
figure, imshow(gray_img); hold on;
plot(u, v, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
hold off;