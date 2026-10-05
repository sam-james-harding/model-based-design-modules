-- 1-to-4 demux for 8-bit values. D goes to whichever output sel picks, and the
-- other three are 0.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Demux is
port (
    D: in std_logic_vector(7 downto 0);
    
    Y0: out std_logic_vector(7 downto 0);
    Y1: out std_logic_vector(7 downto 0);
    Y2: out std_logic_vector(7 downto 0);
    Y3: out std_logic_vector(7 downto 0);
    
    sel: in std_logic_vector(1 downto 0)
);
end Demux;

architecture Dataflow of Demux is

begin

with sel select
    Y0 <= D     when "00",
          X"00" when others;
          
with sel select
    Y1 <= D     when "01",
          X"00" when others;
          
with sel select
    Y2 <= D     when "10",
          X"00" when others;
          
with sel select
    Y3 <= D     when "11",
          X"00" when others;

end Dataflow;
