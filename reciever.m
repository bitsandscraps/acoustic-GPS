% A simple oscilloscope & spectrum analyzer using a sound card
% Configure your PC to use microphone as input and adjust the mic volume.
% Written by Sae-Young Chung, 2013
% Last update: 2016/2/29

%% Sound Template Generation
fs = 44100;       % sampling rate
delta = 0.25;
offset = delta * fs;
soundTemplate1 = zeros(offset, 1);
soundTemplate1(1:100) = 1;
soundTemplate4 = repmat(soundTemplate1, 4, 1);
segmentEnd = (1:4) * offset;
nspeakers = 4;
nspeakergroups = 4;
speakerselection = cell(1, nspeakergroups);
speakerselection{1} = 1;
speakerselection{2} = 2;
speakerselection{3} = 3;
speakerselection{4} = 4;
[soundTemplate] = ...
    helper_surround_sound_single_voices(soundTemplate4, segmentEnd, ...
                                        nspeakers, nspeakergroups, ...
                                        speakerselection);

%% DAQ Setup
d=daq.getDevices;   % list of data acquisition (daq) devices
sSpeaker = daq.createSession('directsound');
addAudioOutputChannel(sSpeaker, 'Audio3', 1:4);
sSpeaker.Rate = 44100;
sSpeaker.IsContinuous = true;
listenerSpeaker = ...
    addlistener(sSpeaker,'DataRequired', ...
                @(src,event) src.queueOutputData(soundTemplate));
sMic = daq.createSession('directsound');
addAudioInputChannel(sMic, 'Audio0', 1:2);
sMic.IsContinuous = true;
sMic.Rate = 44100;
sMic.NotifyWhenDataAvailableExceeds = 44100;
callBackMic = @(~, event) callBackHelper(event, delta);
listenerMic = addlistener(sMic, 'DataAvailable', callBackMic);
startBackground(sMic)
queueOutputData(sSpeaker, soundTemplate);
startBackground(sSpeaker);


%% Helper Function
function callBackHelper(event, delta)
offset = round((delta / 2) * 44100);
threshold = 0.01;
x = mean(event.Data, 2);
plot(x)
index1 = find(x > threshold, 1);
if isempty(index1)
    return
end
index2 = find(x(index1 + offset:end) > threshold, 1) + index1 + offset - 1;
if isempty(index2)
    return
end
index3 = find(x(index2 + offset:end) > threshold, 1) + index2 + offset - 1;
if isempty(index3)
    return
end
index4 = find(x(index3 + offset:end) > threshold, 1) + index3 + offset - 1;
if isempty(index4)
    return
end
timestamps = event.TimeStamps([index1 index2 index3 index4]);
timestamps = timestamps - event.TimeStamps(index1);
timestamps = timestamps - (0:3)' * delta;
r = timestamps * 340
% X = [0 1.2 0 1.2];
% Y = [0 0 0.3 0.3];
% display(findPosition(X, Y, r'))
end

