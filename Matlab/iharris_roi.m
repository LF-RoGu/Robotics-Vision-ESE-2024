function [v, u, s, corner_strength] = iharris_roi(image, nfeat, roi)
    % Check if the input image is grayscale
    if size(image, 3) ~= 1
        error('Input image must be a grayscale image.');
    end

    % Extract ROI
    roi_img = imcrop(image, roi);

    % Compute the intensity gradient images Iu and Iv using the Sobel filter
    Iu = imfilter(double(roi_img), fspecial('sobel')');
    Iv = imfilter(double(roi_img), fspecial('sobel'));

    % Compute the squared gradients and the product of gradients
    Iu2 = Iu .^ 2;
    Iv2 = Iv .^ 2;
    Iuv = Iu .* Iv;

    % Define the Gaussian kernel size
    N = 5;

    % Smooth the resulting gradients with a Gaussian kernel
    % calculate gradient images + smoothing (i.e. elements of A-matrix)
    Iu2 = ifilter_gauss(Iu2, N);
    Iv2 = ifilter_gauss(Iv2, N);
    Iuv = ifilter_gauss(Iuv, N);

    % Compute the corner strength matrix
    k = 0.04;
    corner_strength = (Iu2 .* Iv2 - Iuv .^ 2) - k * (Iu2 + Iv2) .^ 2;

    % Find the strongest features within the ROI
    [sorted_strength, indices] = sort(corner_strength(:), 'descend');
    indices = indices(1:nfeat);
    [v, u] = ind2sub(size(corner_strength), indices);
    s = sorted_strength(1:nfeat);
    
    % Adjust the coordinates to be in the context of the original image
    v = v + roi(2);
    u = u + roi(1);