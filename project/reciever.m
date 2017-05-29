% A simple oscilloscope & spectrum analyzer using a sound card
% Configure your PC to use microphone as input and adjust the mic volume.
% Written by Sae-Young Chung, 2013
% Last update: 2016/2/29

d=daq.getDevices;   % list of data acquisition (daq) devices
dev=d(1);           % select the first one

s=daq.createSession('directsound'); % create a daq session
addAudioInputChannel(s, dev.ID, 1:2);  % add audio channel
s.IsContinuous=true;    % continuous mode for continuously capturing audio
s.Rate=44100;              % set the sampling rate
s.NotifyWhenDataAvailableExceeds=44100;
    % If 's.NotifyWhenDataAvailableExceeds' samples are available,
    % 'DataAvailable' event occurs.


clear lab1c_plot plotFunc       % clear if they already exist in the cache

% plotFunc = @(src, event) display(event.TimeStamps(2) - event.TimeStamps(1));
    % define a function plotFunc that calls lab1c_plot.m
    % passing 'h1' and 'h2' in addition to 'src' and 'event' that are passed
    % by the event handler
listener=addlistener(s, 'DataAvailable', @callBack);
    % call plotFunc every time 'DataAvailable' event occurs
    % 'DataAvailable' event will occur whenever s.NotifyWhenDataAvailableExceeds
    % samples are available

global startTime
startTime = now;
startBackground(s)
startTime = startTime * 24 * 3600;

function callBack(~, event)
global sentTime
global startTime
FS = 44100;
FB = 441;
FC = 2000;
M = FS / FB;
x = mean(event.Data, 2);
index = find(x > 0.4, 1);
if ~isempty(index)
    ((sentTime - startTime) - event.TimeStamps(index)) * 340
end
% y1=x'.*cos(2*pi*(FC + freq_offset) * tt + theta);  % multiplication by cosine and sine
% r = rcosdesign(0.3, 50, M); % root raised cosine with roll-off factor 0.3 and span from -25 to 25
% y1f = conv(y1,r);  % matched filtering (since r is symmetric, it does not need to be flipped)
% y1s = y1f(start:M:end);
% for i = 1:(length(y1s) - 4)
%     if sum(y1s(i:i + 4)) == 5
%         break
%     end
% end
% plot(y1s)
% y1s = y1s(i:end);
% if length(y1s) >= 72
%     y1s(6:8)
%     y1s = y1s(9:72);
%     currentTimeUint = uint64(0);
%     for i = 0:7
%         currentTimeUint = bitor(currentTimeUint, uint64(bitshift(uint64(bi2de(y1s(i*8+1:i*8+8), 'right-msb')), 8 * i)));
%     end
%     currentTime = typecast(currentTimeUint, 'double')
% end
end

