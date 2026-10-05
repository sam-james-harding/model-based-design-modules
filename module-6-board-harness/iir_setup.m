%% IIR setup code
% Sets the filter coefficients, data types and microphone settings for the
% Module 6 models, which run this when they load.
% Uses the Signal Processing Toolbox (butter).

%% Filter parameters
Fs = 48e3;                          % sample rate (Hz)
Fc = 1e3;                           % cutoff frequency (Hz)
Ts = 1/Fs;
[b, a] = butter(2, Fc/(Fs/2));      % y[n] = b0 x[n] + b1 x[n-1] + b2 x[n-2] - a1 y[n-1] - a2 y[n-2]

%% look-ahead pipelining
% Multiplying the top and bottom of the transfer function by la cancels the
% y[n-1] term, so the loop only needs y[n-2] and can hold two registers.
la = [1 -a(2) a(3)];
bp = conv(b, la);                   % feed-forward coefficients b0'..b4'
ap = conv(a, la);                   % feedback coefficients a0'..a4' (a1' and a3' come out as 0)

%% fixed-point word lengths
if ~exist('CoeffWL', 'var')
    CoeffWL = 16;                   % coefficient word length
end
InT  = fixdt(1, 16, 15);            % audio in and out: 16 bits, range +-1
SigT = fixdt(1, 24, 20);            % internal signals: 3 integer bits of headroom
OutT = InT;

%% board microphone
Tpdm = 32/100e6;                    % microphone bit period: 100 MHz / 32 = 3.125 MHz
Rdec = 64;                          % decimation: 3.125 MHz / 64 = 48.828 kHz

%% keep generated files (Simulink cache, HDL) in work/
Simulink.fileGenControl('set', 'CacheFolder', 'work', 'CodeGenFolder', 'work', 'createDir', true);
