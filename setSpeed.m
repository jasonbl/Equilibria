function [] = setSpeed(speed)

global actArduino SET_VELOCITY

fprintf(actArduino, SET_VELOCITY);
fprintf(actArduino, speed);
%disp(fscanf(actArduino, '%s'));

end