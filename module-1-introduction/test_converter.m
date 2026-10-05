function test_converter()
% Testbench for converter_matlab: every 8-bit input.
% MATLAB integer arithmetic saturates, so outputs above 255 are held at 255.
    for x = 0:255
        Y = converter_matlab(uint8(x));
        assert(Y == min(2*x + 5, 255), 'Test failed for X = %d', x);
    end
    disp('All 256 tests passed.');
end
