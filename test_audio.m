load handel;
d = daq.getDevices;
%
% Create a data acquisition session using |directSound| as the vendor ID.
% DirectSound sound cards are available on all windows platforms.
%
s = daq.createSession('directsound');
addAudioOutputChannel(s, 'Audio3', 1:4);
s.Rate = Fs;
segmentEnd = [20000, 36000, 45000, 55000, length(y)];
nspeakers = 4;
nspeakergroups = 4;
speakerselection = cell(1, nspeakergroups);
speakerselection{1} = 1; % Segment 1; speakers 4 and 6
speakerselection{2} = 2; % Segment 2; speakers 4 and 5
speakerselection{3} = 3; % Segment 3; speakers 1 and 4
speakerselection{4} = 4; % Segment 4; speakers 2 and 4
[singleChannelOutputs] = ...
    helper_surround_sound_single_voices(y, segmentEnd, nspeakers, nspeakergroups, speakerselection);
queueOutputData(s, singleChannelOutputs);
startForeground(s);
pause(3);