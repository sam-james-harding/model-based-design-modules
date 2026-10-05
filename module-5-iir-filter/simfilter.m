function y = simfilter(mdl, x, useDouble)
% SIMFILTER  Runs filter model MDL on the samples in X and returns its output.
% Y = SIMFILTER(MDL, X) rounds X to the 16-bit input type and simulates in
% fixed point, the way the hardware would.
% Y = SIMFILTER(MDL, X, true) overrides every data type to double instead, so
% you see what the filter structure does with no rounding at all.
% Either way, Y lags X by one sample, the same as the hardware.
    if nargin < 3, useDouble = false; end
    t = (0:numel(x)-1)' * evalin('base', 'Ts');

    in = Simulink.SimulationInput(mdl);
    if useDouble
        in = in.setModelParameter('DataTypeOverride', 'Double');
    else
        x = fi(x, evalin('base', 'InT'));           % quantise to the input port's type
    end
    in = in.setExternalInput(timeseries(x, t));
    in = in.setModelParameter('StopTime', sprintf('%.17g', t(end)));
    out = sim(in);
    y = double(out.yout{1}.Values.Data(:));
end
