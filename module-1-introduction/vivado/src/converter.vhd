library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Converter is
port (
    X: in unsigned(7 downto 0);
    Y: out unsigned(7 downto 0)
);
end Converter;

architecture Dataflow of Converter is

begin

Y <= resize(2*X + 5, 8);

end Dataflow;
