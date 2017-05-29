function x=bpsk_mod(a,fb,fc,fs)
% BPSK modulation
% a: data row vector (+1 or -1)
% fb: baud rate (1/Tb, where Tb = symbol period)
% fc: carrier frequency
% fs: sampling rate, integer multiple of fb
% x: output row vector

n=length(a);    % length of input vector
m=round(fs/fb);
if m~=fs/fb
    error('fs/fb needs to be an integer')
end
s=zeros(1,n*m);
s(1:m:end)=a;   % interpolate by m
r=rcosdesign(0.3,50,m); % root raised cosine with roll-off factor 0.3 and span from -25 to 25
q=conv(s,r);    % pulse shaping filtering
t=(0:length(q)-1)/fs;
x=q.*cos(2*pi*fc*t);
