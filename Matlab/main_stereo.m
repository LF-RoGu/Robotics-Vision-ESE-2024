clear all;
close all;
clc;
% Read the image
img_left = imread('data/image_left_unrect/image_left_unrect_143.jpg');
img_right = imread('data/image_right_unrect/image_right_unrect_143.jpg');

% Convert the image to grayscale
leftGray = rgb2gray(img_left);
rightGray = rgb2gray(img_right);

% Apply Gaussian filter to smooth the images
leftGray = imgaussfilt(leftGray,2);
rightGray = imgaussfilt(rightGray,2);

% Detect corner features using Harris detector
leftCorners = detectHarrisFeatures(leftGray);
rightCorners = detectHarrisFeatures(rightGray);

% Extract feature descriptors using SURF
[leftFeatures, leftValidPoints] = extractFeatures(leftGray, leftCorners);
[rightFeatures, rightValidPoints] = extractFeatures(rightGray, rightCorners);

% Match features using their descriptors
indexPairs = matchFeatures(leftFeatures, rightFeatures);

% Retrieve matched points
matchedLeftPoints = leftValidPoints(indexPairs(:, 1));
matchedRightPoints = rightValidPoints(indexPairs(:, 2));

% Display matched points
figure;
showMatchedFeatures(leftGray, rightGray, matchedLeftPoints, matchedRightPoints);
title('Matched Points Before Rectification');

% Estimate the fundamental matrix using RANSAC
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(matchedLeftPoints, matchedRightPoints, ...
    'Method', 'RANSAC', 'NumTrials', 2000, 'DistanceThreshold', 1e-4);

% Get the inlier points
inlierLeftPoints = matchedLeftPoints(epipolarInliers, :);
inlierRightPoints = matchedRightPoints(epipolarInliers, :);

% Compute the rectification transforms manually
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
    inlierLeftPoints.Location, inlierRightPoints.Location, size(leftGray));

% Transform the images to rectify them
leftRectified = imwarp(leftGray, projective2d(t1), 'OutputView', imref2d(size(leftGray)));
rightRectified = imwarp(rightGray, projective2d(t2), 'OutputView', imref2d(size(rightGray)));

% Display original
figure;
subplot(1, 2, 1);
imshow(leftImage);
title('Original Left Image');

subplot(1, 2, 2);
imshow(rightImage);
title('Original Right Image');

% Display rectified images
figure;
subplot(1, 2, 1);
imshow(leftRectified);
title('Rectified Left Image');

subplot(1, 2, 2);
imshow(rightRectified);
title('Rectified Right Image');

% Display epipolar lines in rectified images
figure;
showMatchedFeatures(leftRectified, rightRectified, inlierLeftPoints, inlierRightPoints);
title('Epipolar Lines in Rectified Images');

% Optional: Display epipolar lines on original images
figure;
subplot(1, 2, 1);
imshow(leftGray);
title('Epipolar Lines on Left Image');
hold on;
epiLines = epipolarLine(fMatrix', inlierRightPoints.Location);
points = lineToBorderPoints(epiLines, size(leftGray));
line(points(:, [1, 3])', points(:, [2, 4])');

subplot(1, 2, 2);
imshow(rightGray);
title('Epipolar Lines on Right Image');
hold on;
epiLines = epipolarLine(fMatrix, inlierLeftPoints.Location);
points = lineToBorderPoints(epiLines, size(rightGray));
line(points(:, [1, 3])', points(:, [2, 4])');
