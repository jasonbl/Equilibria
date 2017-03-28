function[] = setActuatorDirection(actuator, direction)

global actArduino SET_DIRECTION

% Send set direction signal to arduino
fprintf(actArduino, SET_DIRECTION);

% Tell the arduino which actuator to set the direction of
fprintf(actArduino, actuator);

% Tell the arduino which direction the actuator should move in
fprintf(actArduino, direction);

end