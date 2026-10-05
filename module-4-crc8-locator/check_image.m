function [Rc, Cc, ref] = check_image(img)
% Row and column CRC8 checks for a square greyscale image.

    img = uint8(img);
    n   = size(img, 1);
    Rc  = zeros(n, 1, 'uint8');
    Cc  = zeros(n, 1, 'uint8');
    for k = 1:n
        Rc(k) = crc8_line(img(k, :));
        Cc(k) = crc8_line(img(:, k));
    end
    ref = [Rc; Cc];
end
