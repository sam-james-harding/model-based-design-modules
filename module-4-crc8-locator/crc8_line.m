function c = crc8_line(bytes)
% CRC-8 over a vector of bytes

    c = uint8(0);
    b = uint8(bytes(:));
    for n = 1:numel(b)
        c = bitxor(c, b(n));
        for k = 1:8
            if bitand(c, uint8(128)) ~= 0
                c = bitxor(bitshift(c, 1), uint8(7));
            else
                c = bitshift(c, 1);
            end
        end
    end
end
