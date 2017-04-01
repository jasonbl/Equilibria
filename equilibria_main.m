clear;
clc;

global boardWidth boardHeight READ_COP READ_TILT SET_VELOCITY SET_DIRECTION...
    copPlotHandle modeIsStarted modeSelected percentSpeed maxTilt ...
    readArduino actArduino UP DOWN OFF ACTUATOR_ONE ACTUATOR_TWO ...
    adaptiveFirstTime settingTilt

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
zoneRadius = .03; % Length of side of OK zone

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

firstTime = true;
settingTilt = false;
hasJustEnteredCenter = false;
timerRunning = false;
while ~strcmp(modeSelected, 'QUIT')
    %timerVal = tic;
    [currentPitch, currentRoll] = getTilt();
    [copX, copY] = getCOP();
    %toc(timerVal);
    
    % If this is the first time we're drawing the wiiScreen, create a
    % handle for the screen
    if (firstTime)
        zoneHandle = rectangle(copPlotHandle, 'Position', ...
            [-zoneRadius -zoneRadius 2*zoneRadius 2*zoneRadius], ...
            'LineWidth', 3 , 'Curvature', [1 1], 'FaceColor', [0 1 0 .3], ...
            'EdgeColor', [0 1 0]);
        copPlot = plot(copPlotHandle, copX, copY, 'ko-', 'MarkerSize', 14,'MarkerFaceColor',[0 0 0]);
        set(copPlot, 'XDataSource', 'copX', 'YDataSource', 'copY');
        firstTime = false;
    end
    
    % If the board's tilt is being set, change zone color to yellow
    if (settingTilt)
        set(zoneHandle, 'FaceColor', [1 1 0 .3], 'EdgeColor', [1 1 0]);
        hasJustEnteredCenter = false;
        timerRunning = false;
    else
        % Check if center of pressure is outside of OK zone
        distanceFromCenter = sqrt(copX * copX + copY * copY);
        if (distanceFromCenter > zoneRadius)
            set(zoneHandle, 'FaceColor', [1 0 0 .3], 'EdgeColor', [1 0 0]);
            hasJustEnteredCenter = false;
            timerRunning = false;
        else
            set(zoneHandle, 'FaceColor', [0 1 0 .3], 'EdgeColor', [0 1 0]);
            
            % Set hasJustEnteredCenter for adaptive mode
            if ~hasJustEnteredCenter && ~timerRunning
                %disp('Just Entered Zone');
                hasJustEnteredCenter = true;
            else
                hasJustEnteredCenter = false;
            end
        end
    end
    
    if strcmp(modeSelected, 'REACTIVE')
        
        % Check if center of pressure is outside of OK zone
        if (distanceFromCenter > zoneRadius)
            % Actuator one controls roll, positive roll = actuator up
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
            
            % Actuator two controls pitch, positive pitch = actuator up
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
            % If user is in OK zone, begin to level board
            setTilt(0, 0, currentPitch, currentRoll);
        end
    elseif strcmp(modeSelected, 'ADAPTIVE')
        % Generate new circle if too close to center?
        
        % adaptiveFirstTime set to true when start button for adaptive mode
        % is pressed
        if adaptiveFirstTime || goToNextTilt
            % Generate random pitch and random roll in range (-maxTilt maxTilt)
            randomPitch = (2 * rand - 1) *  maxTilt;
            randomRoll = (2 * rand - 1) * maxTilt;
            
            % Intialize variables for adaptive mode
            goToNextTilt = false;
            settingTilt = true;
            timerRunning = false;
        end
        
        %disp(hasJustEnteredCenter);
        
        adaptiveFirstTime = false;
        if settingTilt
            settingTilt = ~setTilt(randomPitch, randomRoll, currentPitch, currentRoll);
        elseif hasJustEnteredCenter
            % Begin timer if the tilt is set and the user has just entered the
            % OK zone
            timerVal = tic;
            timerRunning = true;
            hasJustEnteredCenter = false;
        end
        
        if timerRunning
            % If user has been centered in OK zone for 2 seconds, go to
            % next tilt
            if toc(timerVal) >= 2
                goToNextTilt = true;
                timerRunning = false;
            end
        end
    elseif strcmp(modeSelected, 'LEVEL_BOARD')
        % Takes in arguments: desiredPitch, desiredRoll, currentPitch,
        % currentRoll
        if settingTilt
            settingTilt = ~setTilt(0, 0, currentPitch, currentRoll);
        else
            modeSelected = 'OFF';
        end
    end
    
    % Redraw the COP Plot
    refreshdata(copPlot);
    drawnow;
end

% Level board after the quit button is pressed
setSpeed(50);
settingTilt = true;
while settingTilt
    [currentPitch, currentRoll] = getTilt();
    settingTilt = ~setTilt(0, 0, currentPitch, currentRoll);
end

% Stop serial communication
fclose(readArduino);
fclose(actArduino);
