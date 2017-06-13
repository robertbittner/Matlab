function playSuccessToneATWM1()
%Choose a sampling rate fs, e.g. 8000 Hz. (You'll need a higher rate if
%you want sounds above 4000 Hz).
fs = 8000;

%Generate time values from 0 to T seconds at the desired rate.
T = 0.25; % 2 seconds duration
t = 0:(1/fs):T;

%Generate a sine wave of the desired frequency f at those times.
%f = 2000;
f = [1000 1500 2000];
a = 0.5;
for c = 1:numel(f)
    y = a*sin(2*pi*f(c)*t);
    sound(y, fs);
    pause(0.5);
end


end