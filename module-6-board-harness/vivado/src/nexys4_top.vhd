library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nexys4_top is
  generic (RECORD_MS : natural := 4000);
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;
    BTNC       : in  std_logic;
    SW         : in  std_logic_vector(1 downto 0);
    LED        : out std_logic_vector(15 downto 0);
    M_CLK      : out std_logic;
    M_DATA     : in  std_logic;
    M_LRSEL    : out std_logic;
    AUD_PWM    : out std_logic;
    AUD_SD     : out std_logic);
end entity;

architecture rtl of nexys4_top is
  signal rst_sync : std_logic_vector(1 downto 0) := "11";
  signal rst      : std_logic;
  signal sw_meta  : std_logic_vector(1 downto 0) := "00";
  signal sw_s     : std_logic_vector(1 downto 0) := "00";
  signal btn_meta : std_logic := '0';
  signal btn_s    : std_logic := '0';
  signal pdm_bit  : std_logic;
  signal bit_en   : std_logic;
  signal strobe   : std_logic;
  signal mic      : std_logic_vector(15 downto 0);
  signal playback : signed(15 downto 0);
  signal duty     : std_logic_vector(10 downto 0);
  signal leds     : std_logic_vector(14 downto 0);
begin
  -- synchronise the reset button, the record button and the switches
  process (CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      rst_sync <= rst_sync(0) & not CPU_RESETN;
      sw_meta  <= SW;
      sw_s     <= sw_meta;
      btn_meta <= BTNC;
      btn_s    <= btn_meta;
    end if;
  end process;
  rst <= rst_sync(1);

  -- microphone
  u_mic_clock : entity work.mic_clock
    port map (clk => CLK100MHZ, m_data => M_DATA, m_clk => M_CLK,
              pdm_bit => pdm_bit, bit_en => bit_en);

  -- generated from mic_decimator.slx
  u_decimator : entity work.mic_decimator
    port map (clk => CLK100MHZ, reset => rst, clk_enable => bit_en, pdm => pdm_bit,
              ce_out => strobe, sample => mic);

  -- record while BTNC is held, then play back on a loop
  u_recorder : entity work.recorder
    generic map (MAX => RECORD_MS * 48828 / 1000)
    port map (clk => CLK100MHZ, en => strobe, rec => btn_s, din => signed(mic),
              dout => playback);

  -- generated from board_audio.slx
  u_audio : entity work.board_audio
    port map (clk => CLK100MHZ, reset => rst, clk_enable => strobe,
              playback => std_logic_vector(playback), add_tone => sw_s(1),
              bypass => sw_s(0), recording => btn_s, mic => mic,
              ce_out => open, duty => duty, leds => leds);

  -- audio output: 11-bit PWM at 48.828 kHz
  u_pwm : entity work.pwm_out
    port map (clk => CLK100MHZ, duty => duty, pwm => AUD_PWM);

  M_LRSEL <= '0';                         -- microphone channel select: data valid at the rising edge
  AUD_SD  <= '1';                         -- enable the audio amplifier
  LED     <= leds & sw_s(0);
end architecture;
