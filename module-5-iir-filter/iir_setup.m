%% IIR setup code
% Sets everything the Module 5 scripts and models need. Every step script runs
% this first, and the models run it when they load.
% Uses the Signal Processing Toolbox (butter, resample).

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
tol  = 2^-9;                        % testbench tolerance: 16 LSBs of the 16-bit output

%% audio sample: 4s of Handel with added noise
S = load('handel.mat');
clip = resample(S.y(1:4*S.Fs), Fs, S.Fs);
clip = 0.5 * clip / max(abs(clip));
rng(0);
noisy = max(min(clip + 0.05*randn(size(clip)), 1), -1);
clear S

%% keep generated files (Simulink cache, HDL) in work/
Simulink.fileGenControl('set', 'CacheFolder', 'work', 'CodeGenFolder', 'work', 'createDir', true);
