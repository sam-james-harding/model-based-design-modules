%% Step 4: audio testbench
CoeffWL = 8;
iir_setup                                   % also sets tol, the allowed difference

%% filter the noisy clip with the reference and the design
yRef = filter(b, a, noisy);                 % reference: double precision
yRef = [0; yRef(1:end-1)];                  % match the design's one-sample latency
yDut = simfilter('iir_pipelined', noisy);   % design: fixed point

%% plot the difference against the tolerance
err = abs(yDut - yRef);
t = (0:numel(noisy)-1)' * Ts;
figure; plot(t, err, t, tol*ones(size(t)), 'r--');
xlabel('Time (s)'); legend('|Difference|', 'Tolerance');

%% check the difference
fprintf('Largest difference %.2e, tolerance %.2e\n', max(err), tol);

%% play the input, the reference and the design
sound(noisy, Fs);  pause(numel(noisy)/Fs + 1);
sound(yRef, Fs);   pause(numel(noisy)/Fs + 1);
sound(yDut, Fs);
