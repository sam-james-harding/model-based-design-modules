-- 11-bit PWM for the audio output
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_out is
  port (
    clk  : in  std_logic;
    duty : in  std_logic_vector(10 downto 0);    -- 0 (always low) to 2047 (almost always high)
    pwm  : out std_logic := '0');
end entity;

architecture rtl of pwm_out is
  signal count  : unsigned(10 downto 0) := (others => '0');
  signal duty_r : unsigned(10 downto 0) := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then
      count <= count + 1;
      if count = 0 then
        duty_r <= unsigned(duty);
      end if;
      if count < duty_r then pwm <= '1'; else pwm <= '0'; end if;
    end if;
  end process;
end architecture;
