clc;
clear;
close all;

%% Declarations
M = 2;
h1 = -0.5+0.75j;
h2 = 0.29+0.81j;
r = 3;
H = [[h1 h2 0 0];[0 h1 h2 0];[0 0 h1 h2]];
in = randi([0,1],1,64*1024);

%% Modulation
xmod = pskmod(in,M);
x = xmod;
x_1 = circshift(xmod,1); x_1(1)=0;
x1 = circshift(xmod,-1); x1(end)=0;
x2 = circshift(xmod,-2); x2(end-1:end)=0;
X = [x2;x1;x;x_1];

ber1 = [];
ber2 = [];

for snr=1:1:40
    
    Y = H*X;
    Y_noise = awgn(Y(1,:),snr,'measured');
    
    noise = Y_noise-Y(1,:);
    noise_1 = circshift(noise,-1);
    noise_1(end) = 0;
    noise_2 = circshift(noise,-2);
    noise_2(end-1:end) = 0;
    Y_final = (H*X) + [noise_2;noise_1;noise];    
    C=  (inv(H*H')*H)*[0;0;1;0];
    Y_equ = C'*Y_final;
    x_without_demod = pskdemod(Y_final,2);
    x_with_demod = pskdemod(Y_equ,2);
    [N1,error1] = biterr(in,x_without_demod(1,:));
    [N2,error2] = biterr(in,x_with_demod);
    ber1 = [ber1,error1];
    ber2 = [ber2,error2];
end

%% Plotting
semilogy(1:1:40,ber1,'-b',1:1:40,ber2,'-g'); grid on;
legend('BPSK Without ZF','BPSK with ZF');
title('SNR vs BER');
xlabel('SNR');
ylabel('BER');