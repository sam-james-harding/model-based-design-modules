%% Step 2: pipelined filter
iir_setup

%% compare filter output (double precision)
imp = [1; zeros(199, 1)];
fprintf('Largest difference, audio:   %.2e\n', max(abs(simfilter('iir_original', noisy, true) - simfilter('iir_pipelined', noisy, true))));
fprintf('Largest difference, impulse: %.2e\n', max(abs(simfilter('iir_original', imp, true) - simfilter('iir_pipelined', imp, true))));

%% compare filter output (quantised to 16 bits)
hO = simfilter('iir_original', imp/2) * 2;
hP = simfilter('iir_pipelined', imp/2) * 2;
fprintf('Largest difference, fixed-point impulse: %.2e\n', max(abs(hO - hP)));

%% plot impulse response for original and pipelined filter
figure; stem(0:199, [hO hP]); xlim([0 60]); legend('Original', 'Pipelined'); xlabel('n');
title(sprintf('Fixed-point impulse responses, %d-bit coefficients', CoeffWL));
