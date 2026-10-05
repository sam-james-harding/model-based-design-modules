%% Step 5: measured frequency response
CoeffWL = 8;
iir_setup
N = 8192;

%% impulse response of the fixed-point model
h = simfilter('iir_pipelined', [0.5; zeros(N-1, 1)]) * 2;  % half-scale impulse
h = h(2:end);                                              % drop the one-sample latency

%% fourier transform, and the ideal response
f = (1:N/2-1)' * Fs/N;
H = fft(h, N);
H = H(2:N/2);
Hideal = freqz(b, a, f, Fs);

%% Bode plot
figure;
subplot(2, 1, 1); semilogx(f, 20*log10(abs(Hideal)), f, 20*log10(abs(H)), '--');
ylabel('Magnitude (dB)'); ylim([-80 5]); legend('Ideal', 'Measured');
subplot(2, 1, 2); semilogx(f, rad2deg(unwrap(angle(Hideal))), f, rad2deg(unwrap(angle(H))), '--');
ylabel('Phase (degrees)'); xlabel('Frequency (Hz)'); ylim([-200 0]);
