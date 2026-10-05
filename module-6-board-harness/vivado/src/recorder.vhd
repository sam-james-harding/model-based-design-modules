-- Records a sample stream into block RAM while 'rec' is high, then plays the
-- recording back on a loop. Outputs silence while recording.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity recorder is
  generic (MAX : natural);                         -- longest recording, in samples
  port (
    clk  : in  std_logic;
    en   : in  std_logic;                          -- one pulse per sample
    rec  : in  std_logic;
    din  : in  signed(15 downto 0);
    dout : out signed(15 downto 0) := (others => '0'));
end entity;

architecture rtl of recorder is
  type ram_t is array (0 to MAX-1) of signed(15 downto 0);
  signal ram       : ram_t;
  signal waddr     : natural range 0 to MAX := 0;  -- next sample to record
  signal raddr     : natural range 0 to MAX-1 := 0; -- next sample to play
  signal len       : natural range 0 to MAX := 0;  -- length of the recording
  signal recording : std_logic := '0';
  signal data      : signed(15 downto 0) := (others => '0');
begin
  process (clk)
    variable a : natural range 0 to MAX;
  begin
    if rising_edge(clk) then
      if en = '1' then
        recording <= rec;
        if rec = '1' then
          if recording = '0' then a := 0; else a := waddr; end if;   -- start a new recording
          if a < MAX then
            ram(a) <= din;
            waddr <= a + 1;
            len <= a + 1;
          end if;
          raddr <= 0;
          data <= (others => '0');
        elsif len > 0 then
          data <= ram(raddr);
          if raddr >= len - 1 then raddr <= 0; else raddr <= raddr + 1; end if;
        end if;
      end if;
      dout <= data;
    end if;
  end process;
end architecture;
