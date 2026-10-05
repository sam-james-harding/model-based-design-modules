function ok = run_demo()
% RUN_DEMO  Checks that crc8_locator finds a corrupted pixel.
% Loads the reference CRCs for capybara32.png into the model, then runs it on
% the clean image and on five copies that each have one pixel changed. Prints
% where the model found the error each time, how many clock cycles a run
% takes, and PASS or FAIL. Returns true if every run was right.
    mdl   = 'crc8_locator';
    spots = [19 12; 1 1; 32 32; 1 5; 3 32];   % (row, col) of each bad pixel

    RUN = 7000; % cycles START is held high for each run, longer than a run takes
    GAP = 3;    % cycles of START low between runs, so the controller resets

    img         = imread('capybara32.png'); % 32 x 32, 8-bit greyscale
    [~, ~, ref] = check_image(img);
    npx         = numel(img);

    % the clean image first, then one copy per entry in spots, each with that
    % pixel changed by 137 (any non-zero change would do)
    imgs = cell(1, size(spots, 1) + 1);
    imgs{1} = img;
    for m = 1:size(spots, 1)
        r = spots(m, 1);
        c = spots(m, 2);
        bad = img;
        bad(r, c) = uint8(mod(double(img(r, c)) + 137, 256));
        imgs{m + 1} = bad;
    end

    % stimulus, one row per clock cycle: write the 64 reference CRCs once,
    % then for each image write its 1024 pixels and hold START high for a run
    N  = 64 + numel(imgs) * (npx + RUN + GAP);
    s  = struct('start',       false(N, 1), ...
                'img_wr_addr', zeros(N, 1, 'uint16'), ...
                'img_wr_data', zeros(N, 1, 'uint8'),  ...
                'img_wr_en',   false(N, 1), ...
                'ref_wr_addr', zeros(N, 1, 'uint16'), ...
                'ref_wr_data', zeros(N, 1, 'uint8'),  ...
                'ref_wr_en',   false(N, 1));

    k = 0;
    j = (1:64)';
    s.ref_wr_addr(k + j) = uint16(j - 1);
    s.ref_wr_data(k + j) = ref;
    s.ref_wr_en(k + j)   = true;
    k = k + 64;

    first = zeros(1, numel(imgs));
    j     = (1:npx)';
    for m = 1:numel(imgs)
        p = imgs{m}'; % row-major order
        s.img_wr_addr(k + j) = uint16(j - 1);
        s.img_wr_data(k + j) = p(:);
        s.img_wr_en(k + j)   = true;
        k = k + npx;

        first(m) = k + 1; % cycle this run starts on
        s.start(k + (1:RUN)) = true;
        k = k + RUN + GAP;
    end

    % run the model
    if ~bdIsLoaded(mdl), load_system(mdl); end

    t  = (0:N - 1)';
    in = fieldnames(s);
    ds = Simulink.SimulationData.Dataset;
    for m = 1:numel(in)
        ds = ds.addElement(timeseries(s.(in{m}), t), in{m});
    end

    si = Simulink.SimulationInput(mdl);
    si = si.setExternalInput(ds);
    si = si.setModelParameter('StopTime',       num2str(N - 1), ...
                              'SaveOutput',     'on', ...
                              'SaveFormat',     'Dataset', ...
                              'OutputSaveName', 'yout');
    out = sim(si);

    done = logical(out.yout{1}.Values.Data(:));
    er   = double(out.yout{2}.Values.Data(:));
    ec   = double(out.yout{3}.Values.Data(:));
    ev   = logical(out.yout{4}.Values.Data(:));

    % read each run's result on the first cycle DONE goes high
    ok = true;
    fprintf('\n  run  image           reported        expected        \n');
    for m = 1:numel(imgs)
        w = first(m) - 1 + find(done(first(m):first(m) + RUN - 1), 1);
        if isempty(w)
            error('run_demo:noDone', 'run %d never finished', m);
        end

        r = er(w) + 1;      % the model counts from 0, MATLAB from 1
        c = ec(w) + 1;
        if ev(w), rep = sprintf('(%d,%d)', r, c); else, rep = 'no error'; end

        if m == 1
            what = 'clean';
            exp  = 'no error';
            good = ~ev(w);
        else
            what = sprintf('pixel (%d,%d)', spots(m - 1, 1), spots(m - 1, 2));
            exp  = sprintf('(%d,%d)', spots(m - 1, 1), spots(m - 1, 2));
            good = ev(w) && r == spots(m - 1, 1) && c == spots(m - 1, 2);
        end

        fprintf('  %3d  %-15s %-15s %-15s %s\n', m, what, rep, exp, tick(good));
        ok = ok && good;
    end

    % clocks from START to DONE, timed on the second run (every run takes the same)
    n = first(2) - 1 + find(done(first(2):first(2) + RUN - 1), 1) - first(2) + 1;
    fprintf('\n%d clocks per run (%.1f us at 100 MHz)\n', n, n / 100);
    if ok
        fprintf('PASS\n');
    else
        fprintf('FAIL\n');
    end
end

% -------------------------------------------------------------------------
function s = tick(b)
    if b, s = 'ok'; else, s = 'FAIL'; end
end
