clc;
clear;
close all;
% Read the image
pathFolderRight = 'C:\Users\Luis\OneDrive - FH Dortmund\FH-Dortmund\2 Semester\Robotics\Robotics Vision ESE 2024\data\image_right_unrect';
pathFolderLeft = 'C:\Users\Luis\OneDrive - FH Dortmund\FH-Dortmund\2 Semester\Robotics\Robotics Vision ESE 2024\data\image_left_unrect';
imageFileName = 'image_right_unrect_0.jpg'; % Change this to your image file name

% Construct the full path to the image file
fullImagePath = fullfile(pathFolderRight, imageFileName);

img = imread(fullImagePath);

% Convert the image to HSV color space
hsvImg = rgb2hsv(img);

% Define the color ranges for black and gray
% Note: Adjust these ranges based on your specific image and color shades

% Black color range (HSV)
blackMin = [0, 0, 0]; % Min HSV value for black
blackMax = [180/255, 255/255, 50/255]; % Max HSV value for black

% Gray color range (HSV)
grayMin = [0, 0, 50/255]; % Min HSV value for gray
grayMax = [180/255, 50/255, 200/255]; % Max HSV value for gray

% Create masks for black and gray colors
blackMask = (hsvImg(:,:,1) >= blackMin(1) & hsvImg(:,:,1) <= blackMax(1)) & ...
            (hsvImg(:,:,2) >= blackMin(2) & hsvImg(:,:,2) <= blackMax(2)) & ...
            (hsvImg(:,:,3) >= blackMin(3) & hsvImg(:,:,3) <= blackMax(3));
        
grayMask = (hsvImg(:,:,1) >= grayMin(1) & hsvImg(:,:,1) <= grayMax(1)) & ...
           (hsvImg(:,:,2) >= grayMin(2) & hsvImg(:,:,2) <= grayMax(2)) & ...
           (hsvImg(:,:,3) >= grayMin(3) & hsvImg(:,:,3) <= grayMax(3));

% Find the coordinates of the black and gray pixels
[blackY, blackX] = find(blackMask);
[grayY, grayX] = find(grayMask);

% Display the results
figure;
imshow(img);
hold on;
plot(blackX, blackY, 'r.', 'MarkerSize', 10); % Plot black pixels in red
plot(grayX, grayY, 'b.', 'MarkerSize', 10); % Plot gray pixels in blue
title('Tracked Colors: Black (red), Gray (blue)');
hold off;

% Display coordinates
disp('Black Pixel Coordinates:');
disp([blackX, blackY]);

disp('Gray Pixel Coordinates:');
disp([grayX, grayY]);
