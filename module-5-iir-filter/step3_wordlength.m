%% Step 3: coefficient word length
iir_setup
N = 8192;
imp = [0.5; zeros(N-1, 1)];                 % impulse
f = (1:N/2-1)' * Fs/N;                      % frequencies to plot (Hz)
ideal = 20*log10(abs(freqz(b, a, f, Fs)));
band = ideal > -40;                         % compare where the response is above -40 dB

%% simulate both filters at each word length
wordLengths = [4 8 16];
figure;
for i = 1:numel(wordLengths)
    CoeffWL = wordLengths(i);
    orig = magnitude(simfilter('iir_original', imp) * 2, N);
    pipe = magnitude(simfilter('iir_pipelined', imp) * 2, N);

    subplot(1, numel(wordLengths), i);
    semilogx(f, ideal, 'k', f, orig, f, pipe, '--');
    title(sprintf('%d-bit coefficients', CoeffWL));
    xlabel('Frequency (Hz)'); ylabel('dB'); xlim([10 Fs/2]); ylim([-80 5]);
    fprintf('%2d bits: worst error %.2f dB original, %.2f dB pipelined\n', CoeffWL, ...
        max(abs(orig(band) - ideal(band))), max(abs(pipe(band) - ideal(band))));
end
legend('Ideal', 'Original', 'Pipelined', 'Location', 'southwest');
clear CoeffWL                               % back to the default word length

%% magnitude response (dB) of an impulse response h
function db = magnitude(h, N)
    H = fft(h(2:end), N);                   % drop the one-sample latency
    db = 20*log10(abs(H(2:N/2)));
end
