%% Step 1: original filter
iir_setup

%% play sound before and after filtering
sound(noisy, Fs);  pause(numel(noisy)/Fs + 1);
sound(filter(b, a, noisy), Fs);

%% plot error between model and ideal filter
ySim = simfilter('iir_original', noisy, true);
yRef = filter(b, a, noisy);
yRef = [0; yRef(1:end-1)];              % the model has one sample of latency

t = (0:numel(noisy)-1)' * Ts;
figure; plot(t, noisy, t, yRef, t, ySim, '--');
xlim([1 1.02]); xlabel('Time (s)'); legend('Input', 'filter()', 'Simulink model');

%% compute MAPE
fprintf('MAPE, model vs filter(): %.2e%%\n', mean(abs(ySim - yRef)./(yRef+1e-9)) * 100);
