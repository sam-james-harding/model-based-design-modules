-- 4-to-4 switch. The mux picks one of D0-D3 using sel_in, and the demux sends
-- it to one of Y0-Y3 using sel_out. The other three outputs stay at 0.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Switch is
port (
    D0: in std_logic_vector(7 downto 0);
    D1: in std_logic_vector(7 downto 0);
    D2: in std_logic_vector(7 downto 0);
    D3: in std_logic_vector(7 downto 0);
    
    Y0: out std_logic_vector(7 downto 0);
    Y1: out std_logic_vector(7 downto 0);
    Y2: out std_logic_vector(7 downto 0);
    Y3: out std_logic_vector(7 downto 0);
    
    sel_in: in std_logic_vector(1 downto 0);
    sel_out: in std_logic_vector(1 downto 0)
);
end Switch;

architecture Structural of Switch is

component Mux is
port (
    D0: in std_logic_vector(7 downto 0);
    D1: in std_logic_vector(7 downto 0);
    D2: in std_logic_vector(7 downto 0);
    D3: in std_logic_vector(7 downto 0);
    
    Y: out std_logic_vector(7 downto 0);
    
    sel: in std_logic_vector(1 downto 0)
);
end component;

component Demux is 
port (
    D: in std_logic_vector(7 downto 0);
    
    Y0: out std_logic_vector(7 downto 0);
    Y1: out std_logic_vector(7 downto 0);
    Y2: out std_logic_vector(7 downto 0);
    Y3: out std_logic_vector(7 downto 0);
    
    sel: in std_logic_vector(1 downto 0)
);
end component;

signal selected_input: std_logic_vector(7 downto 0);

begin

mux4to1: Mux
port map (D0 => D0, D1 => D1, D2 => D2, D3 => D3, sel => sel_in, Y => selected_input);

demux1to4: Demux
port map (D => selected_input, Y0 => Y0, Y1 => Y1, Y2 => Y2, Y3 => Y3, sel => sel_out);


end Structural;
