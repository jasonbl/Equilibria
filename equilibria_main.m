clear;
clc;

global boardWidth boardHeight READ_COP READ_TILT SET_VELOCITY SET_DIRECTION...
    copPlotHandle modeIsStarted modeSelected percentSpeed maxTilt

boardWidth = .433; % distance (width) between strain gauges (m)
boardHeight = .238; % distance ((height) between strain gauges (m)
READ_COP = 'R';
READ_TILT = 'T';
SET_VELOCITY = 'V';
SET_DIRECTION = 'D';
modeIsStarted = false; % initially no mode has begun
modeSelected = 'ADAPTIVE'; % initial mode
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

% % Set velocity for actuators
% % fprintf(actArduino, SET_VELOCITY);
% % fprintf(actArduino, 128);
% % disp(fscanf(actArduino, '%f'));

% Read data from Wii Board
firstTime = true;
while ~strcmp(modeSelected, 'QUIT')
    %timerVal = tic;
    [pitch, roll] = getTilt(readArduino);
    [copX, copY] = getCOP(readArduino);
    %toc(timerVal);
    
    % If this is the first time we're drawing the wiiScreen, create a
    % handle for the screen
    if (firstTime)
        copPlot = plot(copPlotHandle, copX, copY, 'ko-', 'MarkerSize', 14,'MarkerFaceColor',[0 0 0]);
        set(copPlot, 'XDataSource', 'copX', 'YDataSource', 'copY');
        firstTime = false;
    end
    
    if strcmp(modeSelected, 'REACTIVE')
        % SET SPEED
        % SET MAX TILT
        
          % Actuator control
        if (abs(copX) > .125 * boardWidth)
            fprintf(actArduino, SET_DIRECTION);
            % Actuator to control
            fprintf(actArduino, ACTUATOR_ONE);

            if (copX > 0)
                % Direction to move actuator
                fprintf(actArduino, UP); % UP
            else
                % Direction to move actuator
                fprintf(actArduino, DOWN); % DOWN
            end
        else
            fprintf(actArduino, SET_DIRECTION);
            % Actuator to control
            fprintf(actArduino, ACTUATOR_ONE);
            % disp(fscanf(actArduino, '%d'));
            % Actuator OFF
            fprintf(actArduino, OFF);
            % disp(fscanf(actArduino, '%d'));
        end

        if (abs(copY) > .125 * boardHeight)
            fprintf(actArduino, SET_DIRECTION);
            % Actuator to control
            fprintf(actArduino, ACTUATOR_TWO);

            if (copY > 0)
                % Direction to move actuator
                fprintf(actArduino, UP); % UP
            else
                % Direction to move actuator
                fprintf(actArduino, DOWN); % DOWN
            end
        else
            fprintf(actArduino, SET_DIRECTION);
            % Actuator to control
            fprintf(actArduino, ACTUATOR_TWO);
            % Actuator OFF
            fprintf(actArduino, OFF);
        end
    elseif strcmp(modeSelected, 'ADAPTIVE')
    elseif strcmp(modeSelected, 'LEVEL_BOARD')
    end
    
    % Redraw the COP Plot
    refreshdata(copPlot);
    drawnow;
end

% Stop serial communication
fclose(readArduino);
fclose(actArduino);
