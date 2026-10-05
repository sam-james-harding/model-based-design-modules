function test_four_to_four_switch()
% TEST_FOUR_TO_FOUR_SWITCH  Testbench for four_to_four_switch_matlab.
% Tries 100 random inputs and select values, and stops at the first one that
% doesn't match the expected output. HDL Coder also runs this to find out
% what types the inputs are (all uint8).
    rng(1);
    numTests = 100;

    for test = 1:numTests
        % Random uint8 inputs
        D0 = uint8(randi([0 255]));
        D1 = uint8(randi([0 255]));
        D2 = uint8(randi([0 255]));
        D3 = uint8(randi([0 255]));
        sel_in = uint8(randi([0 3]));
        sel_out = uint8(randi([0 3]));

        % DUT
        [Y0, Y1, Y2, Y3] = four_to_four_switch_matlab( ...
            D0, D1, D2, D3, sel_in, sel_out);

        % Reference: the chosen input on the chosen output, 0 everywhere else
        inputs = [D0 D1 D2 D3];
        expected_input = inputs(double(sel_in) + 1);

        expected = uint8([0 0 0 0]);
        expected(double(sel_out) + 1) = expected_input;

        % Compare
        assert(isequal([Y0 Y1 Y2 Y3], expected), ...
            'Test failed on test %d', test);
    end

    fprintf('All %d tests passed.\n', numTests);

end
