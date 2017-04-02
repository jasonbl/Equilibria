function varargout = seniordesignboard(varargin)
% SENIORDESIGNBOARD MATLAB code for seniordesignboard.fig
%      SENIORDESIGNBOARD, by itself, creates a new SENIORDESIGNBOARD or raises the existing
%      singleton*.
%
%      H = SENIORDESIGNBOARD returns the handle to a new SENIORDESIGNBOARD or the handle to
%      the existing singleton*.
%
%      SENIORDESIGNBOARD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SENIORDESIGNBOARD.M with the given input arguments.
%
%      SENIORDESIGNBOARD('Property','Value',...) creates a new SENIORDESIGNBOARD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before seniordesignboard_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to seniordesignboard_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help seniordesignboard

% Last Modified by GUIDE v2.5 01-Apr-2017 23:57:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @seniordesignboard_OpeningFcn, ...
                   'gui_OutputFcn',  @seniordesignboard_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before seniordesignboard is made visible.
function seniordesignboard_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to seniordesignboard (see VARARGIN)

% Choose default command line output for seniordesignboard
handles.output = hObject;

global copPlotHandle boardWidth boardHeight copXField copYField pitchField...
    rollField weightField

copPlotHandle = handles.COP_Plot;
copXField = handles.copXField;
copYField = handles.copYField;
pitchField = handles.pitchField;
rollField = handles.rollField;
weightField = handles.weightField;
% if (~isempty(copPlotHandle))
%     disp('Found plot');
% end

% Set up the axes for graphing the output of the simulation.
axis equal;
axis([-boardWidth/2 boardWidth/2 -boardHeight/2 boardHeight/2]);
axes = gca;
%axes.XTick = [-boardWidth/2, 0, boardWidth/2];
%axes.YTick = [-boardHeight/2, 0, boardHeight/2];
axes.XTick = 0;
axes.YTick = 0;
axes.XTickLabel = [];
axes.YTickLabel = [];
%xlabel('Horizontal Position (m)')
%ylabel('Vertical Position (m)')
hold on; box on; grid on;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes seniordesignboard wait for user response (see UIRESUME)
% uiwait(handles.equilibriaGUI);


% --- Outputs from this function are returned to the command line.
function varargout = seniordesignboard_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global modeSelected modeIsStarted percentSpeed maxTilt adaptiveFirstTime...
    copXVariance copYVariance numSamples ACTUATOR_ONE ACTUATOR_TWO OFF...
    settingTilt

if ~modeIsStarted
    % Initialize COP variances and numSamples for stability index
    % calculations
    copXVariance = 0;
    copYVariance = 0;
    numSamples = 0;
    
    h = get(handles.modeSelectionButtonGroup, 'SelectedObject');
    selection = get(h, 'Tag');
    %disp(selection);
    
    prompt = {'Enter the desired percent speed of the board (as an integer between 25 and 100):',
        'Enter the desired maximum degree of tilt of the board (as an integer between 0 and 15):'};
    % CHANGE RANGE OF MAX TILT MAYBE? (raise lower bound)
    dlg_title = 'Difficulty Input';
    num_lines = 1;
    defaultans = {sprintf('%d', percentSpeed), sprintf('%d', maxTilt)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    % Make sure user didn't hit cancel button
    if size(answer) ~= 0
        % Check for invalid inputs
        input1 = floor(str2double(answer{1}));
        input2 = floor(str2double(answer{2}));
        if (input1 < 25 || input1 > 100)
            msgbox('Invalid speed input. Please input an integer between 25 and 100', ...
                'Invalid Speed');
            return;
        end
        if (input2 < 0 || input2 > 15)
            msgbox('Invalid tilt angle input. Please input an integer between 0 and 15', ...
                'Invalid Tilt');
            return;
        end
        
        % Set global variables
        percentSpeed = input1;
        maxTilt = input2;
        
        % Set new speed of actuators
        setSpeed(percentSpeed);
        setAngleDelta(percentSpeed);
        
        if strcmp(selection, 'reactiveButton')
            modeSelected = 'REACTIVE';
        elseif strcmp(selection, 'adaptiveButton')
            modeSelected = 'ADAPTIVE';
            adaptiveFirstTime = true;
        end
        set(handles.start, 'String', 'Stop');
        set(handles.start, 'BackgroundColor', 'red');
        modeIsStarted = true;
    end
else
    modeSelected = 'OFF';
    setActuatorDirection(ACTUATOR_ONE, OFF);
    setActuatorDirection(ACTUATOR_TWO, OFF);
    settingTilt = false;
    set(handles.start, 'String', 'Start');
    set(handles.start, 'BackgroundColor', [.73 .83 .96]);
    modeIsStarted = false;
    
    % Calculate stability indexes and display to user
    APSI = sqrt(copYVariance / numSamples);
    MLSI = sqrt(copXVariance / numSamples);
    OSI = sqrt((copXVariance + copYVariance) / numSamples);
    msgbox(sprintf('%s\n\nAPSI (range: 0 - 11.9) = %.1f\nMLSI (range: 0 - 21.7) = %.1f\n OSI (range: 0 - 24.7) = %.1f', ...
        'For more information about stability index, please see the Help button above.',...
        APSI, MLSI, OSI),...
        'Stability Index Information');
end

% --- Executes on button press in levelBoard.
function levelBoard_Callback(hObject, eventdata, handles)
% hObject    handle to levelBoard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global modeSelected modeIsStarted settingTilt angleDelta

if modeIsStarted
    % Tell user that board can't be leveled while mode is in progress
    msgbox('Error: the board cannot be leveled while a mode is in progress', ...
        'Levelling Error');
else
    setSpeed(40); % Set speed to 40%
    angleDelta = 0;
    settingTilt = true;
    modeSelected = 'LEVEL_BOARD';
end

% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles)
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global modeSelected
modeSelected = 'QUIT';
delete(handles.equilibriaGUI);

% --------------------------------------------------------------------
function helpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to helpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Don't delete
function equilibriaGUI_WindowButtonDownFcn(hObject, eventdata, handles)

% --- Executes when user attempts to close equilibriaGUI.
function equilibriaGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to equilibriaGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function aboutEquilibria_Callback(hObject, eventdata, handles)
% hObject    handle to aboutEquilibria (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox(sprintf('%s\n\n%s', 'Equilibria is a smart standing balance training system designed for children with cerebral palsy. The device consists of a plate that has the ability to tilt in two degrees of freedom at constant speeds and maximum tilt angles that can be set by a physical therapist. It can support up to 100 lbs. The board is intended to improve the balance of children with cerebral palsy while also building muscle strength and developing faster reaction times.', ...
    'The device was developed from 2016-2017 at the University of Pennsylvania by Justin Averback, Jason Bleiweiss, Ashley Collimore, Lisa Sesink-Clee,  Meredith Spann, and Ni Yang as part of their capstone engineering project.'), 'About Equilibria');


% --------------------------------------------------------------------
function stabilityIndex_Callback(hObject, eventdata, handles)
% hObject    handle to stabilityIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox(sprintf('%s\n\n%s\n\n%s\n\n%s\n\n%s\n%s','All stability indices are based on the calculations of similar indices for the BIODEX Balance System SD.',...
    'Anterior/Posterior Stability Index (APSI): The root mean square of center of pressure variance along the Y axis. A high APSI score may be indicative of poor neuromuscular control of the quadriceps and/or hamstring muscles and the anterior/posterior compartment muscles of the lower leg.',...
    'Medial/Lateral Stability Index (MLSI): The root mean square of center of pressure variance along the X axis. A high MLSI score may be indicative of poor neuromuscular control of the inversion or eversion muscles of the lower leg, both bilaterally and unilaterally.',...
    'Overall Stability Index (OSI): A composite of the APSI and MLSI scores, sensitive to center of pressure variance in both the X and Y axes.',...
    'Source:', 'Rohleder, Peter Alexander. "Validation of Balance Assessment Measures of an Accelerometric Mobile Device Application Versus a Balance Platform." Thesis. Wichita State University, 2012. Print.'), 'Stability Index');


% --- Executes on button press in decreaseZoneSize.
function decreaseZoneSize_Callback(hObject, eventdata, handles)
% hObject    handle to decreaseZoneSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zoneRadius zoneHandle
if zoneRadius - .01 > 0
    zoneRadius = zoneRadius - .01;
end
set(zoneHandle, 'Position', [-zoneRadius -zoneRadius 2*zoneRadius 2*zoneRadius]);

% --- Executes on button press in increaseZoneSize.
function increaseZoneSize_Callback(hObject, eventdata, handles)
% hObject    handle to increaseZoneSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global zoneRadius zoneHandle
if zoneRadius < .1
    zoneRadius = zoneRadius + .01;
end
set(zoneHandle, 'Position', [-zoneRadius -zoneRadius 2*zoneRadius 2*zoneRadius]);
