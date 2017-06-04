% EE405C<Network of Smart Systems> Final Project - Wed 1(Acoustic GPS)
% receiver.m
% Copyright 2017 by KIM Kwanwoo and PARK Jongeui
% First written: 2017-05-24
% Last updated:  2017-06-04

%% Figure Setup
f = figure(1);
f.MenuBar = 'none';
f.Position = f.Position + [0 -200 0 150];
width = f.Position(3);
plot(NaN, NaN, 'o-')
hold on
plot(NaN, NaN, 'o-')
hold off
ax = gca;
ax.Box = 'on';
ax.XLim = xlimits;
ax.YLim = ylimits;
ax.XLimMode = 'manual';
ax.YLimMode = 'manual';
ratio = (xlimits(2) - xlimits(1)) / (ylimits(2) - ylimits(1));
pbaspect([ratio 1 1])
ax.Units = 'pixels';
ax.Position = ax.Position + [0 0 0 200];
grid on
textbox_pos = annotation('textbox');
textbox_pos.FontSize = 15;
textbox_pos.HorizontalAlignment = 'center';
textbox_pos.VerticalAlignment = 'middle';
textbox_pos.Units = 'pixels';
textbox_pos.Position = [0.1 * width, 150, 0.5 * width, 50];
textbox_pos.BackgroundColor = 'white';
uicontrol('Style', 'togglebutton', 'String', 'Draw', ...
          'Position', [0.7 * width, 150, 0.2 * width, 50], ...
          'FontSize', 12, 'Callback', @callbackDraw);
uicontrol('Style', 'pushbutton', 'String', 'Clear', ...
          'Position', [0.1 * width, 50, 0.2 * width, 50], ...
          'FontSize', 12, 'Callback', @callbackClear)
uicontrol('Style', 'pushbutton', 'String', 'Done', ...
          'Position', [0.4 * width, 50, 0.2 * width, 50], ...
          'FontSize', 12, 'Callback', @callbackDone)
uicontrol('Style', 'pushbutton', 'String', 'Close', ...
          'Position', [0.7 * width, 50, 0.2 * width, 50], ...
          'FontSize', 12, 'Callback', @callbackClose);

%% DAQ Setup
global sMic
d = daq.getDevices;
sMic = daq.createSession('directsound');
addAudioInputChannel(sMic, 'Audio0', 1:2);
sMic.IsContinuous = true;
sMic.Rate = fs;
sMic.NotifyWhenDataAvailableExceeds = fs * delta * 4;
callBackMic = @(~, event) callBackHelper(event, delta, textbox_pos, ...
                                         xlimits, ylimits);
listenerMic = addlistener(sMic, 'DataAvailable', callBackMic);
startBackground(sMic);

function callBackHelper(event, delta, tbPos, xlimits, ylimits)
global X
global Y
global init
offset = round((delta / 2) * 44100);
THRESHOLD = 0.05;
TEMPERATURE = 26.5;   % in degrees Celsius
speedOfSound = 331.3 * sqrt(1 + TEMPERATURE / 273.15);
x = diff(mean(event.Data, 2));
% Code for Debugging
% figure(2)
% plot(x)
index1 = find(x > THRESHOLD, 1);
if isempty(index1)
    return
end
index2 = find(x(index1 + offset:end) > THRESHOLD, 1) + index1 + offset - 1;
if isempty(index2)
    return
end
index3 = find(x(index2 + offset:end) > THRESHOLD, 1) + index2 + offset - 1;
if isempty(index3)
    return
end
index4 = find(x(index3 + offset:end) > THRESHOLD, 1) + index3 + offset - 1;
if isempty(index4)
    return
end
timestamps = event.TimeStamps([index1 index2 index3 index4]);
timestamps = timestamps - event.TimeStamps(index1);
timestamps = timestamps - (0:3)' * delta;
r = timestamps * speedOfSound;
pos = findPosition(r') * 100;
if init
    while (pos(1) > 30) || (pos (2) > 30)
        X = X([2 3 4 1]);
        Y = Y([2 3 4 1]);
        pos = findPosition(r') * 100;
    end
    init = false;
end
if pos(1) < xlimits(1) || pos(1) > xlimits(2) ...
        || pos(2) < ylimits(1) || pos(2) > ylimits(2)
    return
end
figure(1)
ax = gca;
if isempty(ax.Children(1).XData)
    % need to continue the stroke
    stroke = ax.Children(2);
    strokeX = [stroke.XData pos(1)];
    strokeY = [stroke.YData pos(2)];
    set(stroke, 'XData', strokeX, 'YData', strokeY)
else
    % need to update the current position
    set(ax.Children(1), 'XData', pos(1), 'YData', pos(2))
end
tbPos.String = sprintf('x = % 2.1f    y = % 2.1f', pos(1), pos(2));
end

function callbackDraw(hObject, ~)
figure(1)
ax = gca;
if hObject.Value == hObject.Min     % the button is off (not drawing)
    set(ax.Children(1), 'XData', NaN, 'YData', NaN);
    % cut the stroke
    stroke = ax.Children(2);
    strokeX = [stroke.XData NaN];
    strokeY = [stroke.YData NaN];
    set(stroke, 'XData', strokeX, 'YData', strokeY)
else                                % the button is on (drawing)
    set(ax.Children(1), 'XData', [], 'YData', []);
end
end

function callbackClear(~, ~)
figure(1)
ax = gca;
set(ax.Children(2), 'XData', [], 'YData', [])
end

function callbackDone (~, ~)
%% Leave only the lines
figure(1)
ax = gca;
ax.Children(1).Marker = 'none';
ax.Children(2).Marker = 'none';
original_cond = {ax.XColor, ax.YColor, ax.XTick, ax.YTick};
ax.XColor = 'none';
ax.YColor = 'none';
ax.XTick = [];
ax.YTick = [];
grid off
%% Image processing
F = getframe;
result = frame2im(F);   %% TODO - use result
figure
imshow(result)
%% Recover original state
figure(1)
ax.XColor = original_cond{1};
ax.YColor = original_cond{2};
ax.XTick = original_cond{3};
ax.YTick = original_cond{4};
grid on
ax.Children(1).Marker = 'o';
ax.Children(2).Marker = 'o';
end

function callbackClose(~, ~)
global sMic
global sSpeaker
stop(sMic)
stop(sSpeaker)
delete(figure(1))
end