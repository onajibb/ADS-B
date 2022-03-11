function [y] = Mon_Welch(x, NFFT,Fe)
%MON_WELCH : estimation de la DSP

Nb_fft = round(length(x)/NFFT);
y = zeros(1, NFFT);

for i=0:Nb_fft-1
    X = x(i*NFFT+1:(i+1)*NFFT);
    temp = abs(fftshift(fft(X))).^2;
    y(:) = y(:)+temp;
end

y=y/Nb_fft;
end


