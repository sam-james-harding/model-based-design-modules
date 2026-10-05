-- PDM microphone interface for the Nexys4.
-- Clocks the microphone at 100 MHz / 32 = 3.125 MHz and decimates its 1-bit
-- stream by 64 with a 4th-order CIC filter, giving one 16-bit sample every
-- 2048 clock cycles (48.828 kHz), marked by a one-cycle pulse on 'strobe'.
-- A DC-blocking high-pass (about 8 Hz) removes the microphone's offset.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pdm_mic is
  generic (GAIN_SHIFT : natural := 2);             -- extra gain of 2^GAIN_SHIFT
  port (
    clk    : in  std_logic;                        -- 100 MHz
    rst    : in  std_logic;
    m_clk  : out std_logic;                        -- to the microphone
    m_data : in  std_logic;                        -- from the microphone
    sample : out signed(15 downto 0);
    strobe : out std_logic);
end entity;

architecture rtl of pdm_mic is
  constant W : natural := 26;                      -- 1 + 4*log2(64) + sign bit
  type acc_t is array (1 to 4) of signed(W-1 downto 0);
  signal cnt      : unsigned(10 downto 0) := (others => '0');
  signal data_r   : std_logic := '0';
  signal integ    : acc_t := (others => (others => '0'));
  signal comb_dly : acc_t := (others => (others => '0'));
  signal cic      : signed(W-1 downto 0) := (others => '0');   -- CIC output
  signal dc_acc   : signed(W+10 downto 0) := (others => '0');  -- DC estimate x 1024
begin
  m_clk <= cnt(4);

  process (clk)
    variable c : signed(W-1 downto 0);
    variable d : acc_t;
    variable y : signed(W downto 0);
    constant TOP : natural := 24 - GAIN_SHIFT;     -- full scale is 2^24
  begin
    if rising_edge(clk) then
      strobe <= '0';
      data_r <= m_data;
      if rst = '1' then
        cnt <= (others => '0');
        integ <= (others => (others => '0'));
        comb_dly <= (others => (others => '0'));
        cic <= (others => '0');
        dc_acc <= (others => '0');
        sample <= (others => '0');
      else
        cnt <= cnt + 1;

        -- Integrators, once per PDM bit (just before the rising edge of m_clk)
        if cnt(4 downto 0) = "01111" then
          if data_r = '1' then
            integ(1) <= integ(1) + 1;
          else
            integ(1) <= integ(1) - 1;
          end if;
          for i in 2 to 4 loop
            integ(i) <= integ(i) + integ(i-1);
          end loop;
        end if;

        -- Combs, once per output sample
        if cnt = 2047 then
          c := integ(4);
          d := comb_dly;
          for i in 1 to 4 loop
            comb_dly(i) <= c;
            c := c - d(i);
          end loop;
          cic <= c;
        end if;

        -- One cycle later: remove DC and scale
        if cnt = 0 then
          -- Remove DC: subtract a slowly moving average (time constant 1024 samples)
          y := resize(cic, W+1) - dc_acc(W+10 downto 10);
          dc_acc <= dc_acc + y;
          -- Scale to 16 bits, saturating
          if y < 2**TOP and y >= -(2**TOP) then
            sample <= y(TOP downto TOP-15);
          elsif y > 0 then
            sample <= to_signed(32767, 16);
          else
            sample <= to_signed(-32768, 16);
          end if;
          strobe <= '1';
        end if;
      end if;
    end if;
  end process;
end architecture;
