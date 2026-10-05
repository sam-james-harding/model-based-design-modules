-- Simulation testbench for the Nexys4 harness.
-- A sigma-delta model of the microphone plays a tone while BTNC is held. The
-- testbench checks the output is silent while recording, then measures the
-- tone's amplitude in the playback at the PWM output, with the filter on,
-- bypassed, and with noise added.
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity tb_nexys4_top is
end entity;

architecture sim of tb_nexys4_top is
  signal clk     : std_logic := '0';
  signal resetn  : std_logic := '0';
  signal btnc    : std_logic := '0';
  signal sw      : std_logic_vector(1 downto 0) := "00";
  signal led     : std_logic_vector(15 downto 0);
  signal m_clk, m_data, m_lrsel, aud_pwm, aud_sd : std_logic;
  signal freq    : real := 400.0;
  signal level   : integer := 0;          -- PWM high time over the last 2048 cycles
  signal done    : boolean := false;
begin
  clk <= not clk after 5 ns when not done;   -- stopping the clock ends the simulation

  dut : entity work.nexys4_top
    generic map (RECORD_MS => 30)              -- short, to keep the simulation quick
    port map (CLK100MHZ => clk, CPU_RESETN => resetn, BTNC => btnc, SW => sw, LED => led,
              M_CLK => m_clk, M_DATA => m_data, M_LRSEL => m_lrsel,
              AUD_PWM => aud_pwm, AUD_SD => aud_sd);

  -- Microphone: first-order sigma-delta modulation of a sine, amplitude 0.1
  mic : process
    variable acc, fb : real := 0.0;
  begin
    wait until falling_edge(m_clk);
    if acc >= 0.0 then m_data <= '1'; fb := 1.0; else m_data <= '0'; fb := -1.0; end if;
    acc := acc + 0.1 * sin(MATH_2_PI * freq * real(now / 1 ns) * 1.0e-9) - fb;
  end process;

  -- Measure the PWM duty cycle
  meter : process (clk)
    variable n, k : integer := 0;
  begin
    if rising_edge(clk) then
      if aud_pwm /= '0' then n := n + 1; end if;
      k := k + 1;
      if k = 2048 then level <= n; n := 0; k := 0; end if;
    end if;
  end process;

  stim : process
    variable quiet, pass, stop, byp, noisy : real;

    -- Half the peak-to-peak PWM level over the given number of samples
    procedure measure(name : string; windows : natural; amp : out real) is
      variable hi : integer := 0;
      variable lo : integer := 2048;
      variable a  : real;
    begin
      for i in 1 to windows loop
        wait for 20.48 us;
        if level > hi then hi := level; end if;
        if level < lo then lo := level; end if;
      end loop;
      a := real(hi - lo) / 2.0;
      report name & ": amplitude " & real'image(a) & " PWM counts";
      amp := a;
    end procedure;
  begin
    wait for 1 us;
    resetn <= '1';

    -- Record 20 ms of 400 Hz, checking the output is silent meanwhile
    freq <= 400.0;
    btnc <= '1';
    wait for 2 ms;
    measure("400 Hz, while recording", 150, quiet);
    wait for 15 ms;
    btnc <= '0';
    wait for 2 ms;                                 -- let the filter settle
    measure("400 Hz, filtered", 250, pass);

    -- Record 20 ms of 8 kHz, then play it filtered, bypassed, and with noise
    freq <= 8000.0;
    btnc <= '1';
    wait for 20 ms;
    btnc <= '0';
    wait for 2 ms;
    measure("8 kHz, filtered", 200, stop);
    sw <= "01";
    wait for 0.2 ms;
    measure("8 kHz, bypassed", 200, byp);
    sw <= "11";
    wait for 0.2 ms;
    measure("8 kHz, bypassed with noise", 200, noisy);

    assert quiet < 5.0          report "Output not silent while recording" severity error;
    assert pass > 300.0          report "Pass-band tone too quiet" severity error;
    assert stop < pass / 10.0    report "Stop-band tone not attenuated" severity error;
    assert byp > 10.0 * stop     report "Bypass does not bypass the filter" severity error;
    assert noisy > byp + 50.0    report "SW1 does not add noise" severity error;
    report "Testbench finished";
    done <= true;
    wait;
  end process;
end architecture;
