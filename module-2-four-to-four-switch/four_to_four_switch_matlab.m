function [Y0, Y1, Y2, Y3] = four_to_four_switch_matlab(D0, D1, D2, D3, sel_in, sel_out)
% FOUR_TO_FOUR_SWITCH_MATLAB  Sends one of four 8-bit inputs to one of four outputs.
% sel_in (0-3) picks the input from D0-D3, and sel_out (0-3) picks which of
% Y0-Y3 it comes out on. The other three outputs are 0.
% This is the function HDL Coder turns into VHDL.

    % pick the input
    switch sel_in
        case 0
            selected_input = D0;
        case 1
            selected_input = D1;
        case 2
            selected_input = D2;
        otherwise
            selected_input = D3;
    end

    % outputs default to 0, and uint8 tells HDL Coder they're 8 bits wide
    Y0 = uint8(0);
    Y1 = uint8(0);
    Y2 = uint8(0);
    Y3 = uint8(0);

    % send it to the chosen output
    switch sel_out
        case 0
            Y0 = selected_input;
        case 1
            Y1 = selected_input;
        case 2
            Y2 = selected_input;
        otherwise
            Y3 = selected_input;
    end
end

