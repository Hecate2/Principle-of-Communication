clear all;
close all;
hold off;

%%
N_LP = 100;                          % number of loops;
tSym = 1;                            % symbol period;
fs = 10;                             % sampling frequency;
ts = 1/fs;                           % sampling period;
N_SP_PER_SYM = tSym/ts;              % number of samples per symbol;

N_SYM = 100;                         % number of symbols per loop;
N_FFT = N_SYM * tSym * fs;           % total number of samples;

t_sp = [0: N_SP_PER_SYM-1]/N_SP_PER_SYM * tSym;           % sampling time within a symbol;
gm = ones(1, N_SP_PER_SYM);          % pulse of non-return to zero;
% gm = [ones(1, N_SP_PER_SYM/2) zeros(1, N_SP_PER_SYM/2)];          % pulse of return to zero;
% gm = [ones(1, N_SP_PER_SYM/2) -ones(1, N_SP_PER_SYM/2)];          % pulse of return to zero;

b = randi([0 1],1, N_SYM);           % randomly generate 0,1,  length N_SYM symbols
% b = 2*randi([0 1],1, N_SYM)-1;           % randomly generate +1,-1,  length N_SYM symbols

t_int = kron( [0: N_SYM-1], ones(1, N_SP_PER_SYM) ) * tSym;  
t_fra = kron( ones(1, length(b)), t_sp );
tline = t_int + t_fra;               % sampling time of the whole sequence;


% stem(tline, wa);
%%
sfpwave = zeros(1, length(tline));
for i = 1: N_LP
    
    b = randi([0 7],1, N_SYM)*2-7;           % randomly generate 0,1,  length N_SYM symbols
%     b = 2*randi([0 1],1, N_SYM)-1;           % randomly generate +1,-1,  length N_SYM symbols
    wa = kron(b, gm);                    % wave form;
    % stem(tline, wa);

    sf = fft(wa, N_FFT);                     
    sfpw = abs(sf).^2;                  % related to the power spectrum density;
    sfpwave = sfpwave + sfpw;        

    sfpwave_now = sfpwave/i;            % averaged over Number of loops;
    sfpwave_now = [sfpwave_now(N_FFT/2+1 : N_FFT) sfpwave_now(1 : N_FFT/2)];
    sfpwave_dB = 10*log10(sfpwave_now);      % in dB;

    f_line = [-N_FFT/2 : N_FFT/2-1 ]/N_FFT * fs;
    % figure;
    plot(f_line, sfpwave_dB, '.');
    pause(0.01);

end

figure
plot(wa);
axis([-inf inf -7.5 7.5]);
