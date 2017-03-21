function [pitch, roll] = getTilt(arduino)

global READ_TILT

% Send read request for tilt angles to arduino
fprintf(arduino, READ_TILT);

pitch = fscanf(arduino, '%f');
roll = fscanf(arduino, '%f');

%s = sprintf('Pitch = %.1f ::: Roll = %.1f', pitch, roll);
%disp(s);

end

