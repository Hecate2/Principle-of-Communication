clear all;
close all;

Fs = 44100;                                         % sample frequency;
r = audiorecorder(Fs, 16, 1);                       % please refer to the help in matlab for this function;

%% record the wave;
record(r);                                          % speak into microphone...
tmp = input('press any key to stop');
stop(r);
% pause(2);                                           % wait for 2 second
% p = play(r);                                        % listen to complete recording
mySpeech_a = getaudiodata(r);                         % get data as 'double' array
% mySpeech = getaudiodata(r, 'int16');              % get data as int16 array
% mySpeech = getaudiodata(r, 'int8');               % get data as int8 array

t_start = round(0.2*Fs);
mySpeech = mySpeech_a(t_start:end);                 % cut the first 0.2 second of record;

%% plot the waveform in the time domain;
N = length(mySpeech);                               % the number of total sample points;
Ts = 1/Fs;                                          % sample period;
T = N*Ts;                                           % total duration of this waveform;
x_line = [0:Ts:(N-1)*Ts];                           % x_line in the figure;
plot(x_line, mySpeech);                             % plot the waveform;
% hold on;
xlabel('{\it{t}} seconds', 'FontSize', 16);
ylabel('{\it x(t)}', 'FontSize', 16);
set(gca,'FontSize',16);

%% plot the energy specturm density;
fd_mySpeech = 1/sqrt(N)* fft(mySpeech);             % frequency response of the waveform;
esd_mySpeech_dB = 20*log10(abs(fd_mySpeech));       % energy specturm density of my speech;

B = 5000;  % baseband 5kHz;
N_sel = fix((B/Fs)*N);
esd_plot = [ esd_mySpeech_dB(N-N_sel+2 : N)' esd_mySpeech_dB(1 : N_sel)' ];  % index 1 corresponds to DC component;
df = Fs/N;
f_line = [-B : df : B+10];
f_line = f_line(1: length(esd_plot));

figure;
plot(f_line, esd_plot);
axis([-5000 5000 -70 10]);
xlabel('{\it{f}} Hz', 'FontSize', 16);
ylabel('{\it X(f)}dB', 'FontSize', 16);
set(gca,'FontSize',16);


%% replay the speech;
newSpeech = mySpeech * 3;
rnew = audioplayer(newSpeech, Fs*0.6);
play(rnew);


%% save wave ;
savefile = 'wave_record.mat';
save(savefile, 'mySpeech', 'Fs');



