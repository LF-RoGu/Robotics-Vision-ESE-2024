function [kernel_u, kernel_v] = ifilter_sobel(image)

    %% Init
    im_dim = size(image);
    Iv = zeros(im_dim);
    Iu = zeros(im_dim);

    % Define the Sobel filter kernels
    sobelX = [1 0 -1; 2 0 -2; 1 0 -1];
    sobelY = [1 2 1; 0 0 0; -1 -2 -1];
    % Convolute the image with Sobel kernel
    kernel_u = conv2(double(image), sobelX);
    kernel_v = conv2(double(image), sobelY);
end

