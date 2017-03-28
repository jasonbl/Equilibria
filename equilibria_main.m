clear;
clc;

global boardWidth boardHeight READ_COP READ_TILT SET_VELOCITY SET_DIRECTION...
    copPlotHandle modeIsStarted modeSelected percentSpeed maxTilt ...
    readArduino actArduino UP DOWN OFF ACTUATOR_ONE ACTUATOR_TWO

boardWidth = .433; % distance (width) between strain gauges (m)
boardHeight = .238; % distance ((height) between strain gauges (m)
READ_COP = 'R';
READ_TILT = 'T';
SET_VELOCITY = 'V';
SET_DIRECTION = 'D';
modeIsStarted = false; % initially no mode has begun
modeSelected = 'OFF'; % initially turn selected mode to off
percentSpeed = 0; % initial speed
maxTilt = 0; % initial max tilt
OFF = '0';
UP = '1';
DOWN = '2';
ACTUATOR_ONE = '1';
ACTUATOR_TWO = '2';

% Initialize serial communication with both arduinos
readComPort = '/dev/cu.usbmodem1411';
actComPort = '/dev/cu.usbmodem1451';
[readArduino, serialFlag1] = setupSerial(readComPort);
[actArduino, serialFlag2] = setupSerial(actComPort);

% Begin GUI and get handle to COP Plot
seniordesignboard();
axes(copPlotHandle);

% Set initial percent speed of actuators to 0
setSpeed(0);

% Read data from Wii Board
firstTime = true;
while ~strcmp(modeSelected, 'QUIT')
    %timerVal = tic;
    [currentPitch, currentRoll] = getTilt();
    % NOTE: THE WAY THE ACCELEROMETER IS MOUNTED
    [copX, copY] = getCOP();
    %toc(timerVal);
    
    % If this is the first time we're drawing the wiiScreen, create a
    % handle for the screen
    if (firstTime)
        copPlot = plot(copPlotHandle, copX, copY, 'ko-', 'MarkerSize', 14,'MarkerFaceColor',[0 0 0]);
        set(copPlot, 'XDataSource', 'copX', 'YDataSource', 'copY');
        firstTime = false;
    end
    
    if strcmp(modeSelected, 'REACTIVE')
        % DIFFICULTY SETTINGS - display circle on board?
        
        % Actuator one control, controls roll
        if (abs(copX) > .125 * boardWidth)
            % Postive roll, actuator up
            if (copX > 0)
                if (currentRoll < maxTilt)
                    setActuatorDirection(ACTUATOR_ONE, UP);
                else
                    setActuatorDirection(ACTUATOR_ONE, OFF);
                end
            else
                if (currentRoll > -maxTilt)
                    setActuatorDirection(ACTUATOR_ONE, DOWN);
                else
                    setActuatorDirection(ACTUATOR_ONE, OFF);
                end
            end
        else
            % Stop moving actuatorOne
            setActuatorDirection(ACTUATOR_ONE, OFF);
        end

        % Actuator two control, controls pitch
        if (abs(copY) > .125 * boardHeight)
            % Postive pitch, actuator up
            if (copY > 0)
                if (currentPitch < maxTilt)
                    setActuatorDirection(ACTUATOR_TWO, UP);
                else
                    setActuatorDirection(ACTUATOR_TWO, OFF);
                end
            else
                if (currentPitch > -maxTilt)
                    setActuatorDirection(ACTUATOR_TWO, DOWN);
                else
                    setActuatorDirection(ACTUATOR_TWO, OFF);
                end
            end
        else
            % Stop moving actuatorTwo
            setActuatorDirection(ACTUATOR_TWO, OFF);
        end
    elseif strcmp(modeSelected, 'ADAPTIVE')
        
    elseif strcmp(modeSelected, 'LEVEL_BOARD')
        % Takes in arguments: desiredPitch, desiredRoll, currentPitch,
        % currentRoll
        tiltIsSet = setTilt(0, 0, currentPitch, currentRoll);
        if tiltIsSet
            modeSelected = 'OFF';
        end
    end
    
    % Redraw the COP Plot
    refreshdata(copPlot);
    drawnow;
end

% Stop serial communication
fclose(readArduino);
fclose(actArduino);
