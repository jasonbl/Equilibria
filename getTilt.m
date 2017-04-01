function [pitch, roll] = getTilt()

global READ_TILT readArduino

% Send read request for tilt angles to arduino
fprintf(readArduino, READ_TILT);

pitch = fscanf(readArduino, '%f');
roll = fscanf(readArduino, '%f');

% s = sprintf('Pitch = %.1f ::: Roll = %.1f', pitch, roll);
% disp(s);

end

