function [timing_offset, phase_offset, freq_offset]=find_timing_phase_freq_offset(y,fb,fc,fs)
% Find timing, phase, freq. offsets for QPSK
% This assumes the phase of the first QPSK symbol is pi/4 (part of preamble).
% y: received signal row vector
% fb: baud rate (1/Tb, where Tb = symbol period)
% fc: carrier frequency
% fs: sampling rate, integer multiple of fb
% timing_offset: first index for sampling
% phase_offset: phase offset
% freq_offset: frequency offset
% Written by Sae-Young Chung, 2016
% last update: 2016/04/02

tt=(0:length(y)-1)/fs;
i=sqrt(-1);
ye=y.*exp(2*pi*i*fc*tt);
m=fs/fb;    % this needs to be an integer
rolloff=0.3;
span=25;
r=rcosdesign(rolloff,2*span,m); % root raised cosine
yf=conv(ye,r);  % matched filtering (since r is symmetric, it does not need to be flipped)
t=(0:length(yf)-1)/fs;   % change 't' to match the length of yf

e=1e99;
for k=1:m
    ys=yf(k:m:end);   % sampling
    ya=abs(ys);
    mx=max(ya);
    st=std(ya(find(ya>0.5*mx)));

    if st<e
        e=st;
        timing_offset=k;
    end
end

ys=yf(timing_offset:m:end);

% find the first data symbol and find its phase
dem=max(abs(ys));
sum_phase=0;
n_phase=0;
kfirst=0;
for k=1:length(ys)
    if kfirst==0
        if abs(ys(k))>dem/2
            kfirst=k;
        end
    else
        if abs(ys(k))<dem/2
            break;
        end
        delta_phase=mod(angle(ys(k))-angle(ys(k-1))+pi/4,pi/2)-pi/4;
        sum_phase=sum_phase+delta_phase;
        n_phase=n_phase+1;
    end
end
if n_phase
    delta_phase=sum_phase/n_phase;
else
    delta_phase=0;
end

% freq. offset compensation
freq_offset=-delta_phase*fb/(2*pi);

ye=y.*exp(2*pi*i*(fc+freq_offset)*tt);
yf=conv(ye,r);  % matched filtering (since r is symmetric, it does not need to be flipped)
ys=yf(timing_offset:m:end);

% phase offset compensation
% +pi/4 since the first QPSK symbol is pi/4
if kfirst
    phase_offset=mod(-angle(ys(kfirst))+pi/4,2*pi);
else
    phase_offset=0;
end
