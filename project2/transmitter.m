% EE405C<Network of Smart Systems> Final Project - Wed 1(Acoustic GPS)
% transmitter.m
% Copyright 2017 by KIM Kwanwoo and PARK Jongeui
% First written: 2017-05-26

%% Sound Template Generation
offset = delta * fs;
soundTemplate = zeros(offset * 4, 4);
for i = 0:3
    soundTemplate((offset * i + 1):(offset * i + width), i + 1) = 1;
end
% soundTemplate1 = zeros(offset, 1);
% soundTemplate1(1:50) = 1;
% soundTemplate4 = repmat(soundTemplate1, 4, 1);
% segmentEnd = (1:4) * offset;
% nspeakers = 4;
% nspeakergroups = 4;
% speakerselection = cell(1, nspeakergroups);
% speakerselection{1} = 1;
% speakerselection{2} = 2;
% speakerselection{3} = 3;
% speakerselection{4} = 4;
% [soundTemplate] = ...
%     helper_surround_sound_single_voices(soundTemplate4, segmentEnd, ...
%                                         nspeakers, nspeakergroups, ...
%                                         speakerselection);

%% Start Speaker Session
global sSpeaker
d = daq.getDevices;
sSpeaker = daq.createSession('directsound');
addAudioOutputChannel(sSpeaker, 'Audio3', 1:4);
sSpeaker.Rate = fs;
sSpeaker.IsContinuous = true;
listenerSpeaker = ...
    addlistener(sSpeaker,'DataRequired', ...
                @(src,event) src.queueOutputData(soundTemplate));
for i = 1:ceil(22050 / size(soundTemplate, 1))  % minimum queue is 22050
    queueOutputData(sSpeaker, soundTemplate);
end
startBackground(sSpeaker);