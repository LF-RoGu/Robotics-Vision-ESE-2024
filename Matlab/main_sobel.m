clear all;
close all;
clc;

% Read the image
img = imread('data/image_left_unrect/image_left_unrect_83.jpg');

% Convert the image to grayscale
gray_img = rgb2gray(img);

% Apply the Sobel filter
[kernel_u, kernel_v] = ifilter_sobel(gray_img);

% Display the original image and the edge-detected images
figure;
subplot(1, 3, 1);
imagesc(gray_img);
axis image; % Keep the aspect ratio of the image
colormap gray; % Use grayscale colormap
title('Original Image');

subplot(1, 3, 2);
imagesc(kernel_u);
axis image; % Keep the aspect ratio of the image
colormap gray; % Use grayscale colormap
title('Horizontal Edges');

subplot(1, 3, 3);
imagesc(kernel_v);
axis image; % Keep the aspect ratio of the image
colormap gray; % Use grayscale colormap
title('Vertical Edges');
