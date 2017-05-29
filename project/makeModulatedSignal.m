function makeModulatedSignal (id)
% PREAMBLE = [1 1 1 1 1];
% FC = 2000;        % carrier freq.
% FB = 441;         % baud rate
% FS = 44100;       % sampling rate
% ID_LENGTH = 3;
% NUM_CHANNELS = 2;
% bpskMessage = zeros(12200, NUM_CHANNELS);
% id_bin = bitget(uint8(id), 1:ID_LENGTH);
% message = bitget(typecast(now, 'uint64'), 1:64);
% message = [PREAMBLE id_bin message];
% bpskMessage(:, id) = bpsk_mod(2 * (message - 0.5), FB, FC, FS);
% sound(bpskMessage, FS);
global sentTime
sentTime = now;
sound([1 1 1 1 1])
sentTime = sentTime * 24 * 3600;
end