clear;
clc;

global boardWidth boardHeight

boardWidth = .433; % distance (width) between strain gauges (m)
boardHeight = .238; % distance ((height) between strain gauges (m)

% Initialize serial communication with arduino
comPort = '/dev/tty.usbmodem1411';
[arduino, serialFlag] = setupSerial(comPort);

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

% Read data from Wii Board
firstTime = true;
for i = 1:100
    [copX, copY] = getCOP(arduino);
    
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
