clc;
clear;
close all;

%% Reading Ranges
fileID = fopen('Ranges.dat','r');
a = fread(fileID,'double');
fclose(fileID);

bound = 40;

%% Declarations
errorRate = comm.ErrorRate;
channel = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)');
bpskmod = comm.PSKModulator(2,0,'BitInput',true);
bpskdemod = comm.PSKDemodulator(2,0,'BitOutput',true);
qpskmod = comm.PSKModulator(4,0,'BitInput',true);
qpskdemod = comm.PSKDemodulator(4,0,'BitOutput',true);

SNR=10:1:40;
err=zeros(size(SNR));

for i=1:length(SNR)
    
    channel.SNR = SNR(i);

    if(a(1)<=SNR(i)<a(2))
        
        % BPSK
        M = 2;
        bs = log2(M);
        x = randi([0 1],bs*1000,1);
        tx= bpskmod(x);
        rx = channel(tx);
        decoded = bpskdemod(rx);
               
    elseif(a(2)<=SNR(i)<a(3))
        
        % QPSK
        M = 4;
        bs = log2(M);
        x = randi([0 1],bs*1000,1);
        tx= qpskmod(x);
        rx = channel(tx);
        decoded = qpskdemod(rx);
    
    elseif(a(3)<=SNR(i)<a(4))
        
        % 16-QAM
        M = 16;
        bs = log2(M);
        x = randi([0 1],bs*1000,1);
        tx = qammod(x,M,'bin','InputType','bit');
        rx = awgn(tx,SNR(i),'measured');
        decoded = qamdemod(rx,M,'bin','OutputType','bit');
    
    elseif(a(4)<=SNR(i)<=bound)
        
        % 64-QAM
        M = 64;
        bs = log2(M);
        x = randi([0 1],bs*1000,1);
        tx = qammod(x,M,'bin','InputType','bit');
        rx = awgn(tx,SNR(i),'measured');
        decoded = qamdemod(rx,M,'bin','OutputType','bit');
    
    end
    r = [0 0 0];
    reset(errorRate);
    r = errorRate(x,decoded);
    if (r(1)==0) 
        err(i) = 1e-7;
    else
        err(i) = r(1);
    end
end    

figure;
semilogy(SNR,err);
title('Bit Error Rate - Adaptive Modulation');
xlabel('SNR(dB)');ylabel('Bit Error Rate');