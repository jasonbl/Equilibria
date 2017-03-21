clear;
clc;

global boardWidth boardHeight READ_COP READ_TILT SET_VELOCITY SET_DIRECTION

boardWidth = .433; % distance (width) between strain gauges (m)
boardHeight = .238; % distance ((height) between strain gauges (m)
READ_COP = 'R';
READ_TILT = 'T';
SET_VELOCITY = 'V';
SET_DIRECTION = 'D';

% Initialize serial communication with both arduinos
readComPort = '/dev/cu.usbmodem1411';
actComPort = '/dev/cu.usbmodem1451';
[readArduino, serialFlag1] = setupSerial(readComPort);
[actArduino, serialFlag2] = setupSerial(actComPort);

% Set up the figure for graphing the output of the simulation.
figure(1); clf;
axis equal;
axis([-boardWidth/2 boardWidth/2 -boardHeight/2 boardHeight/2])
axes = gca;
axes.XTick = [-boardWidth/2, 0, boardWidth/2];
axes.YTick = [-boardHeight/2, 0, boardHeight/2];
xlabel('Horizontal Position (m)')
ylabel('Vertical Position (m)')
hold on; box on; grid on;

% Set velocity for actuators
% fprintf(actArduino, SET_VELOCITY);
% fprintf(actArduino, 128);
% disp(fscanf(actArduino, '%f'));

% Read data from Wii Board
firstTime = true;
for i = 1:10000
    %timerVal = tic;
    [pitch, roll] = getTilt(readArduino);
    [copX, copY] = getCOP(readArduino);
    %toc(timerVal);
    
    % Actuator control
    if (abs(copX) > .125 * boardWidth)
        fprintf(actArduino, SET_DIRECTION);
        % Actuator to control
        fprintf(actArduino, '1');
        
        if (copX > 0)
            % Direction to move actuator
            fprintf(actArduino, '2'); % DOWN
        else
            % Direction to move actuator
            fprintf(actArduino, '1'); % UP
        end
    else
        fprintf(actArduino, SET_DIRECTION);
        % Actuator to control
        fprintf(actArduino, '1');
        % disp(fscanf(actArduino, '%d'));
        % Actuator OFF
        fprintf(actArduino, '0');
        % disp(fscanf(actArduino, '%d'));
    end
    
    if (abs(copY) > .125 * boardHeight)
        fprintf(actArduino, SET_DIRECTION);
        % Actuator to control
        fprintf(actArduino, '2');
        
        if (copY > 0)
            % Direction to move actuator
            fprintf(actArduino, '1'); % UP
        else
            % Direction to move actuator
            fprintf(actArduino, '2'); % DOWN
        end
    else
        fprintf(actArduino, SET_DIRECTION);
        % Actuator to control
        fprintf(actArduino, '2');
        % Actuator OFF
        fprintf(actArduino, '0');
    end
    
    % If this is the first time we're drawing the wiiScreen, create a
    % handle for the screen
    if (firstTime)
        wiiScreen = plot(copX, copY, 'ko-', 'MarkerSize', 14,'MarkerFaceColor',[0 0 0]);
        set(wiiScreen, 'XDataSource', 'copX', 'YDataSource', 'copY');
        firstTime = false;
    end
    
    % Redraw the wiiScreen
    refreshdata(wiiScreen);
    drawnow;
end

fclose(arduino);

% Create a welcome screen with mode selection
% Action listeners for mode selection
% Run mode
