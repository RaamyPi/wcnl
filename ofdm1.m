clc;
clear;
close all;

%% Input
snr = 1:1:30;

N = 64^4;
b = randi([0 1], N, 1);

%% Modulation
ymod1 = pskmod(b, 2);
ymod2 = pskmod(b, 4);
ymod3 = qammod(b, 16);
ymod4 = qammod(b, 64);

%% OFDM
[berf1] = odfmul(ymod1,b,1);
[berf2] = odfmul(ymod2,b,2);
[berf3] = odfmul(ymod3,b,3);
[berf4] = odfmul(ymod4,b,4);

%% Plot
semilogy(snr,berf1,'b*-'); hold on;
semilogy(snr,berf2,'r*-'); hold on;
semilogy(snr,berf3,'m*-'); hold on;
semilogy(snr,berf4,'g*-');

title('OFDM - Performance'); 
xlabel("SNR(dB)"); ylabel("Bit Error Rate (BER)"); 
axis([0 30 1e-9 10]);
legend('BPSK','QPSK','16QAM','64QAM');

%% Function Definition
function [ber] = odfmul(ymod,b,y)

    snr = 1:1:30;
    ber = [];
    N = 64^4;
    
    ymod = reshape(ymod, 64, 64^3);
    ym = ifft(ymod, 64);
    ymcp = ym(49:64, :);
    ymcp = [ymcp; ym];

    for i = 1:length(snr)
        
        yn = awgn(ymcp, snr(i), 'measured');
        yn = yn(17:80, :);
        yd = fft(yn, 64);
        ydemod = reshape(yd, 64^4, 1);
        if y==1
            ydemod = pskdemod(ydemod, 2);
        elseif y==2
            ydemod = pskdemod(ydemod, 4);
        elseif y==3
            ydemod = qamdemod(ydemod, 16);
        elseif y==4
            ydemod = qamdemod(ydemod, 64);
        end

        ber(i) = length(find(b~=ydemod))/N;
        
    end

end