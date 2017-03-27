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

% Last Modified by GUIDE v2.5 26-Mar-2017 17:13:13

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

global copPlotHandle boardWidth boardHeight

copPlotHandle = handles.COP_Plot;
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

global modeSelected modeIsStarted percentSpeed maxTilt

if ~modeIsStarted
    h = get(handles.modeSelectionButtonGroup, 'SelectedObject');
    selection = get(h, 'Tag');
    %disp(selection);
    
    prompt = {'Enter the desired percent speed of the board (as an integer between 0 and 100):',
        'Enter the desired maximum degree of tilt of the board (as an integer between 0 and 15):'};
    % CHANGE RANGE OF MAX TILT MAYBE? (raise lower bound)
    dlg_title = 'Difficulty Input';
    num_lines = 1;
    defaultans = {sprintf('%d', percentSpeed), sprintf('%d', maxTilt)};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
    % Check for invalid inputs
    input1 = floor(str2double(answer{1}));
    input2 = floor(str2double(answer{2}));
    if (input1 < 0 || input1 > 100)
        msgbox('Invalid speed input. Please input an integer between 0 and 100', ...
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
    
    if strcmp(selection, 'reactiveButton')
        modeSelected = 'REACTIVE';
    elseif strcmp(selection, 'adaptiveButton')
        modeSelected = 'ADAPTIVE';
    end
    set(handles.start, 'String', 'Stop');
    set(handles.start, 'BackgroundColor', 'red');
    modeIsStarted = true;
else
    modeSelected = 'OFF';
    set(handles.start, 'String', 'Start');
    set(handles.start, 'BackgroundColor', [.73 .83 .96]);
    modeIsStarted = false;
end

% --- Executes on button press in levelBoard.
function levelBoard_Callback(hObject, eventdata, handles)
% hObject    handle to levelBoard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global modeSelected modeIsStarted

if modeIsStarted
    % Tell user that board can't be leveled while mode is in progress
    msgbox('Error: the board cannot be leveled while a mode is in progress', ...
        'Levelling Error');
else
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

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close equilibriaGUI.
function equilibriaGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to equilibriaGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
