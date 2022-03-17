clc;
clear;
close all;

N = 1e6;
b = randi([0 1], N, 1);

ybpsk = pskmod(b, 2);
yqpsk = pskmod(b, 4);
y16q = qammod(b, 16);
y64q = qammod(b, 64);

SnR = 1:0.5:30;
Ebpsk = zeros(1, length(SnR));
Eqpsk = zeros(1, length(SnR));
E16q = zeros(1, length(SnR));
E64q = zeros(1, length(SnR));

for i=1:length(SnR)
    
    rnbpsk = awgn(ybpsk, SnR(i), 'measured');
    rnqpsk = awgn(yqpsk, SnR(i), 'measured');
    rn16q = awgn(y16q, SnR(i), 'measured');
    rn64q = awgn(y64q, SnR(i), 'measured');
    
    dbpsk = pskdemod(real(rnbpsk), 2);
    dqpsk = pskdemod(rnqpsk, 4);
    d16q = qamdemod(rn16q, 16);
    d64q = qamdemod(rn64q, 64);
   
    Ebpsk(i) = (length(find(b~=dbpsk))/N);
    Eqpsk(i) = (length(find(b~=dqpsk))/N);
    E16q(i) = (length(find(b~=d16q))/N);
    E64q(i) = (length(find(b~=d64q))/N);

end

semilogy(10*log10(SnR/2), Ebpsk, 'r.', 10*log10(SnR/2), Eqpsk, 'b*', 10*log10(SnR/2), E16q, 'g-', 10*log10(SnR/2), E64q, 'ko'); grid on;

