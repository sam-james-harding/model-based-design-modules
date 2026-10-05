%% Testbench for multi_adder.slx
% Puts 1000 sets of eight random 8-bit numbers through the model and compares
% each output with the exact sum. A mean squared error of 0 means every sum
% was right.

num_tests = 1000;
delay = 2;      % there's a register before and after the adder, so each
                % sum comes out two clock cycles after its inputs go in

rng(0);         % same inputs every run
t = 0:(num_tests-1);

% the From Workspace blocks in the model read these by name
n1 = timeseries(randi([0 255], 1, num_tests), t);
n2 = timeseries(randi([0 255], 1, num_tests), t);
n3 = timeseries(randi([0 255], 1, num_tests), t);
n4 = timeseries(randi([0 255], 1, num_tests), t);
n5 = timeseries(randi([0 255], 1, num_tests), t);
n6 = timeseries(randi([0 255], 1, num_tests), t);
n7 = timeseries(randi([0 255], 1, num_tests), t);
n8 = timeseries(randi([0 255], 1, num_tests), t);

% run for a couple of extra cycles so the last sums make it out
load_system('multi_adder');
set_param('multi_adder', 'StopTime', num2str(num_tests + delay - 1));
out = sim("multi_adder.slx");

expected_sum = n1.Data(:,:) + ...
    n2.Data(:,:) + ...
    n3.Data(:,:) + ...
    n4.Data(:,:) + ...
    n5.Data(:,:) + ...
    n6.Data(:,:) + ...
    n7.Data(:,:) + ...
    n8.Data(:,:);

% the first two outputs are just the registers' starting values, so skip them
actual_sum = double(out.simout.Data(1+delay:end).');

err = abs(actual_sum - expected_sum);
mse = mean(err .^ 2);

fprintf('Mean squared error: %g\n', mse);

histogram(err);
xlabel('|Model output - exact sum|'); ylabel('Number of samples');
