%#ok<*UNRCH>    % Suppresses unreachable code warning
close all
SIGNAL_TYPES = struct('OUR_LOCAL', 1, 'OUR_RECEIVED', 2, 'TA', 3);
PRINT_FIGURE = false;
sig_name = 'TA';
fc = 2000;  % carrier freq.
fb = 100;   % baud rate
%% Read signal
switch SIGNAL_TYPES.(sig_name)
    case SIGNAL_TYPES.OUR_LOCAL
        x = x_sent;
        fs = fs_sent;
        a_sent = a_sent_OUR;
        b_sent = b_sent_OUR;
        xlimits = [0.4 1];
    case SIGNAL_TYPES.OUR_RECEIVED
        [x, fs] = audioread('lab5_qpsk_received_line - team_1.wav');
        x = x';
        xlimits = [2.2 2.9];
        a_sent = a_sent_OUR;
        b_sent = b_sent_OUR;
    case SIGNAL_TYPES.TA
        [x, fs] = audioread('lab5_ta_qpsk_received.wav');
        x = x';
        xlimits = [1.3 2];
        a_sent = a_sent_TA;
        b_sent = b_sent_TA;
    otherwise
        error('Invalid signal type.')
end
tt = (0:(length(x) - 1)) / fs;
%% Demodulation
[start, theta, freq_offset] = ...
    find_timing_phase_freq_offset(x, fb, fc, fs);
options = [ % to find out how options alters the result
%   none        start       theta       offset  all     is wrong  
    start       1           start       start   1;      % start
    theta       theta       0           theta   0;      % theta
    freq_offset freq_offset freq_offset 0       0;      % freq_offset
    1           2           3           4       5 ];    % string index
option_string = {
    'Correct Demodulation', ...
    'Modified Start', ...
    'Modified Theta', ...
    'Modified Frequency Offset', ...
    'Modified Every Option' };
for opt = options
    start = opt(1);
    theta = opt(2);
    freq_offset = opt(3);
    opt_str = option_string{opt(4)};
    % multiplication by cosine and sine
    y1 = x .* cos(2 * pi * (fc + freq_offset) * tt + theta);
    y2 = x .* sin(2 * pi * (fc + freq_offset) * tt + theta);
    m = fs / fb;    % this needs to be an integer
    % root raised cosine with roll-off factor 0.3 and span from -25 to 25
    r = rcosdesign(0.3, 50, m);
    % matched filtering. r is symmetric, so it does not need to be flipped
    y1f = conv(y1, r);
    y2f = conv(y2, r);
    % change 't' to match the length of y1f and y2f
    t = (0:(length(y1f) - 1)) / fs;
    y1s = y1f(start:m:end);   % sampling
    y2s = y2f(start:m:end);
    ts = t(start:m:end);
    figure  % plot analog signal
    plot(t, y1f, 'b', t, y2f, 'r', ts, y1s, 'o', ts, y2s, 'o')
    xlabel('time [sec]')
    xlim(xlimits)
    if PRINT_FIGURE
        fig_name = sprintf('%s_demodulated(%s).eps', sig_name, opt_str);
        saveas(gcf, fig_name, 'epsc')
    end
    figure  % plot constellation
    plot(y1f, y2f, ':', y1s, y2s, 'o')
    axis equal
    grid on
    xlabel('Real')
    ylabel('Imaginary')
    if PRINT_FIGURE
        fig_name = sprintf('%s_constellation(%s).eps', sig_name, opt_str);
        saveas(gcf, fig_name, 'epsc')
    end
%% Decoding
    count = 0;
    for start=1:length(y1s)
        if (y1s(start) > 0) && (y2s(start) > 0)
            if count == 4   % the length of preamble is 5
                break
            end
            count = count + 1;
        else
            count = 0;
        end
    end
%% Result
    fprintf('%s Signal: %s\n', sig_name, opt_str);
    if ~count
        fprintf('No preamble found.\n');
    else
        start = start - 5;      % include preamble in the signal
        % Quantize the analog signal to 1 and -1
        a1 = (y1s((start + 1):(start + 40)) > 0) * 2 - 1;
        b1 = (y2s((start + 1):(start + 40)) > 0) * 2 - 1;
        figure
        subplot(2, 1, 1)
        stairs(a1, 'LineWidth', 2)
        xlim([0 41])
        ylim([-1.5 1.5])
        title('a')
        subplot(2, 1, 2)
        stairs(b1, 'LineWidth', 2)
        xlim([0 41])
        ylim([-1.5 1.5])
        title('b')
        if PRINT_FIGURE
            fig_name = sprintf('%s_decoded(%s).eps', sig_name, opt_str);
            saveas(gcf, fig_name, 'epsc')
        end
        fprintf('a: %g%%\tb: %g%%\n', ...
            sum(a1 == a_sent) / size(a_sent, 2) * 100, ...
            sum(b1 == b_sent) / size(b_sent, 2) * 100);
    end
end
