function [v, u, s, corner_strength] = iharris(image, nfeat)
    % Check if the input image is grayscale
    if size(image, 3) ~= 1
        error('Input image must be a grayscale image.');
    end

    % Compute the intensity gradient images Iu and Iv using the Sobel filter
    [Iu, Iv] = ifilter_sobel(image);
    
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
    
    % Find the strongest features
    [sorted_strength, indices] = sort(corner_strength(:), 'descend');
    indices = indices(1:nfeat);
    [v, u] = ind2sub(size(corner_strength), indices);
    s = sorted_strength(1:nfeat);
end
