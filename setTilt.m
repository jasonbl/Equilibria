function tiltIsSet = setTilt(desiredPitch, desiredRoll, currentPitch, currentRoll)

global ACTUATOR_ONE ACTUATOR_TWO OFF UP DOWN angleDelta

% Check if roll needs to be altered (controlled by actuator one)
rollIsSet = false;
if abs(currentRoll - desiredRoll) > angleDelta
    
    % MIGHT NEED TO CHANGE THIS DEPENDING ON ACCELEROMETER MOUNTING
    if currentRoll < desiredRoll
        % Increase roll angle closer to desiredRoll
        setActuatorDirection(ACTUATOR_ONE, UP);
    else
        % Decrease roll angle closer to desired Roll
        setActuatorDirection(ACTUATOR_ONE, DOWN);
    end
else
    % Roll is where it needs to be, turn off actuator
    setActuatorDirection(ACTUATOR_ONE, OFF);
    rollIsSet = true;
end


% Check if pitch needs to be altered (controlled by actuator two)
pitchIsSet = false;
if abs(currentPitch - desiredPitch) > angleDelta
    if currentPitch < desiredPitch
        % Increase pitch angle closer to desiredPitch
        setActuatorDirection(ACTUATOR_TWO, UP);
    else
        % Decrease pitch angle closer to desiredPitch
        setActuatorDirection(ACTUATOR_TWO, DOWN);
    end
else
    % Pitch is where it needs to be, turn off actuator
    setActuatorDirection(ACTUATOR_TWO, OFF);
    pitchIsSet = true;
end

tiltIsSet = rollIsSet && pitchIsSet;

end