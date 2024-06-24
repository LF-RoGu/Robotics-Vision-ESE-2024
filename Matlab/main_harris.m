clear all;
close all;
clc;
% Read the image
img = imread('data/image_left_unrect/image_left_unrect_143.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Save the grayscale image
%imwrite(gray_img, 'gray_image.png');

% Apply Gaussian filter
N = 3; % Kernel size
gauss_img = ifilter_gauss(gray_img, N);

% Define the region of interest (ROI)
% Examples:
% [x, y, width, height]
roi = [700, 0, 600, 800]; % Specific area

% Apply Harris filter within the ROI
nfeat = 200; % Number of features to extract
[v, u, s, corner_strength] = iharris_roi(gauss_img, nfeat, roi);

% Plot the Harris corners on the original grayscale image
figure, imshow(gray_img); hold on;
plot(u, v, 'r+', 'MarkerSize', 5, 'LineWidth', 1);
hold off;