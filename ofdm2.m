clc;
clear;
close all;

%% Input
snr = 1:1:15;
berf=[];

N0 = 64^4;
N1 = 256^2;
N2 = 128^2;

b1 = randi([0 1], N0, 1);
b2 = randi([0 1], N1, 1);
b3 = randi([0 1], N2, 1);

%% Modulation
ymod1 = pskmod(b1, 4);
ymod2 = pskmod(b2, 4);
ymod3 = pskmod(b3, 4);

%% Reshaping
ymod1 = reshape(ymod1, 64, 64^3);
ymod2 = reshape(ymod2, 256, 256);
ymod3 = reshape(ymod3, 128, 128);

%% OFDM Symbol Modulation
ym = ifft(ymod1, 64);
ym2 = ifft(ymod2, 256);
ym3 = ifft(ymod3, 128);

%% Adding Cyclic Prefix 
ymcp = ym(49:64, :);
ymcp = [ymcp; ym];

for i = 1:length(snr)
    yn = awgn(ymcp, snr(i), 'measured');
    yn = yn(17:80, :);
    yd = fft(yn, 64);
    ydemod = reshape(yd, 64^4, 1);
    ydemod = pskdemod(ydemod, 4);
    ber = length(find(b1~=ydemod))/N0;
    berf1(i) = ber;
end

ymcp = ym2(193:256, :);
ymcp = [ymcp; ym2];
    for i = 1:length(snr)
    yn = awgn(ymcp, snr(i), 'measured');
    yn = yn(65:320, :);
    yd = fft(yn, 256);
    ydemod = reshape(yd, 256^2, 1);
    ydemod = pskdemod(ydemod, 4);
    ber = length(find(b2~=ydemod))/N0;
    berf2(i) = ber;
end

ymcp = ym3(97:128, :);
ymcp = [ymcp; ym3];
for i = 1:length(snr)
    yn = awgn(ymcp, snr(i), 'measured');
    yn = yn(33:160, :);
    yd = fft(yn, 128);
    ydemod = reshape(yd, 128^2, 1);
    ydemod = pskdemod(ydemod, 4);
    ber = length(find(b3~=ydemod))/N0;
    berf3(i) = ber;
end

%% Plotting
disp(berf);

semilogy(snr,berf1,'b*-'); hold on
semilogy(snr,berf3,'r*-'); hold on
semilogy(snr,berf2,'m*-');

title('OFDM - Performance');
xlabel("SNR(dB)"); ylabel("Bit Error Rate (BER)");
axis([0 17 1e-9 10]);
legend('N0=64','N0=128','N0=256');
