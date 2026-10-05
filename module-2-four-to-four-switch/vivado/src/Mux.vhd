-- 4-to-1 mux for 8-bit values. sel picks which input appears on Y.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux is
port (
    D0: in std_logic_vector(7 downto 0);
    D1: in std_logic_vector(7 downto 0);
    D2: in std_logic_vector(7 downto 0);
    D3: in std_logic_vector(7 downto 0);
    
    Y: out std_logic_vector(7 downto 0);
    
    sel: in std_logic_vector(1 downto 0)
);
end Mux;

architecture Behavioral of Mux is

begin

with sel select
    Y <= D0 when "00",
         D1 when "01",
         D2 when "10",
         D3 when others;

end Behavioral;
