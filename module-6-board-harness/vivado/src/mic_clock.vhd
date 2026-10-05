-- Clock for the PDM microphone: 100 MHz / 32 = 3.125 MHz
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mic_clock is
  port (
    clk     : in  std_logic;                     -- 100 MHz
    m_data  : in  std_logic;                     -- from the microphone
    m_clk   : out std_logic;                     -- to the microphone
    pdm_bit : out std_logic;                     -- the latest bit
    bit_en  : out std_logic);                    -- high for one cycle per bit
end entity;

architecture rtl of mic_clock is
  signal count  : unsigned(4 downto 0) := (others => '0');
  signal data_r : std_logic := '0';
begin
  process (clk)
  begin
    if rising_edge(clk) then
      count  <= count + 1;
      data_r <= m_data;
    end if;
  end process;

  m_clk   <= count(4);
  pdm_bit <= data_r;
  bit_en  <= '1' when count = "01111" else '0';
end architecture;
