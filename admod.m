clc;
clear;
close all;

N = 1e7;
b = randi([0 1], N, 1);

SnR = 1:0.25:30;
E = zeros(1, length(SnR));

for i=1:length(SnR)
    
    if SnR(i) <= 11
        ybpsk = pskmod(b, 2);
        rnbpsk = awgn(ybpsk, SnR(i), 'measured');
        dbpsk = pskdemod(real(rnbpsk), 2);
        E(i) = (length(find(b~=dbpsk))/N);

    elseif SnR(i) <= 18
        yqpsk = pskmod(b, 4);
        rnqpsk = awgn(yqpsk, SnR(i), 'measured');
        dqpsk = pskdemod(rnqpsk, 4);
        E(i) = (length(find(b~=dqpsk))/N);

    elseif SnR(i) <= 24
        y16q = qammod(b, 16);
        rn16q = awgn(y16q, SnR(i), 'measured');
        d16q = qamdemod(rn16q, 16);
        E(i) = (length(find(b~=d16q))/N);
        
    else
        y64q = qammod(b, 64);
        rn64q = awgn(y64q, SnR(i), 'measured');
        d64q = qamdemod(rn64q, 64);
        E(i) = (length(find(b~=d64q))/N);
        
    end

end

semilogy(10*log10(SnR/2), E, 'r.'); grid on;

    