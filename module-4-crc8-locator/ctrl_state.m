classdef ctrl_state < Simulink.IntEnumType
% State names for the CRC error-locator controller.

    enumeration
        IDLE  (0) 
        LOAD  (1)
        HOLD  (2)
        ACC   (3)
        STORE (4)
        SWAP  (5)
        CMP   (6)
        DONE  (7)
    end
end
