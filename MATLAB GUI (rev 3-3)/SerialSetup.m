function varargout = SerialSetup(varargin)
% SERIALSETUP MATLAB code for SerialSetup.fig
%      SERIALSETUP, by itself, creates a new SERIALSETUP or raises the existing
%      singleton*.
%
%      H = SERIALSETUP returns the handle to a new SERIALSETUP or the handle to
%      the existing singleton*.
%
%      SERIALSETUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERIALSETUP.M with the given input arguments.
%
%      SERIALSETUP('Property','Value',...) creates a new SERIALSETUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SerialSetup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SerialSetup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SerialSetup

% Last Modified by GUIDE v2.5 09-Oct-2017 11:58:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SerialSetup_OpeningFcn, ...
                   'gui_OutputFcn',  @SerialSetup_OutputFcn, ...
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


% --- Executes just before SerialSetup is made visible.
function SerialSetup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SerialSetup (see VARARGIN)

    %Add all all of the subfolders of the App's folder to the MATLAB path.
        MyPath = pwd;
        addpath(genpath(MyPath), '-end');

    %Choose default command line output for SerialSetup
        handles.output = hObject;

    %Add in all of the application data that needs to be stored.
        handles.s=0; % serial port
        handles.t_ComExplore =0; % timer (for update GUI and send data)
        handles.COMStart = 0;

        if ~exist('settings','dir') 
            mkdir('settings');
        end
        
        
        
        handles.savePath = 'settings';
        handles.saveFile = 'Current_Serial_Setting.mat';
        handles.jObj=0;
        
        handles.colors = getColors();
        handles.GREEN_COLOR = hex2rgb(handles.colors.LightGreen);
        handles.RED_COLOR = [1 0 0];
        handles.GRAY_COLOR = [0.4706 0.5059 0.4706];
        handles.WHITE_COLOR = [1 1 1];
        
        handles.MainFile = evalin('base','handles.MainFile');
    
    
    %Set up instrument
        %instrreset
        %Load in the last serial settings used.
            if exist(fullfile(handles.savePath, handles.saveFile)) 
                load(fullfile(handles.savePath, handles.saveFile));
                handles.s= s_save;

                %Set the front panel controls accordingly
                    handles.BaudRate.Value = GetBaudEnum(handles.s.BaudRate);
                    %app.COMList.Value = app.s;
            end

        updateCOMPorts(hObject, eventdata, handles);   

        
    %Start the timer
        time_step = 1;
        handles.t_ComExplore = timer;
        handles.t_ComExplore.TimerFcn = @(~, ~)updateCOMPorts(hObject, eventdata, handles);
        handles.t_ComExplore.ExecutionMode = 'fixedRate';
        handles.t_ComExplore.Period = time_step;
        handles.t_ComExplore.BusyMode = 'drop';

        start(handles.t_ComExplore);

        
    %Add icons to buttons
        
%         [x,map,alpha]=imread('ConnectCOMS.png');
%         I2=imresize(x, [32*2 83/2],alpha);
%         handles.ConnectButton.CData=I2;
%         
%         [x,map]=imread('ngc6543a.jpg');
%         I2=imresize(x, [32*2 83/2]);
%         handles.DisconnectButton.CData=I2;     
        


handles.spinnerObj = createSpinner('',hObject,[50,50,36,36]);
handles.spinnerObj.spinner.start;
% Update handles structure

assignin('base', 'handles', handles);
guidata(hObject, handles);

% UIWAIT makes SerialSetup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SerialSetup_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in ConnectButton.
function ConnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %Set up the serial object
        handles.s = serial(handles.COMList.String{handles.COMList.Value});
        handles.s.BaudRate = str2num(handles.BaudRate.String{handles.BaudRate.Value});
        fopen(handles.s);
        handles.COMStart=1;

    %Save the serial object for future use
        s_save=handles.s;
        save(fullfile(handles.savePath, handles.saveFile), 's_save');
        assignin('base', 's_save',s_save);

    % call ReadData function if buffer contains uint16 (2 bytes)
    %app.s.BytesAvailableFcnCount = 2;
    %app.s.BytesAvailableFcnMode = 'byte';
    %app.s.BytesAvailableFcn = @(~, ~)app.ReadData;
   
    %Change the appearance of the buttons
    handles.spinnerObj.spinner.stop;
    delete(handles.spinnerObj.javaObj)
    
    handles.figure1.Color = handles.GREEN_COLOR;
    handles.BaudRateLabel.BackgroundColor = handles.GREEN_COLOR;
    handles.COMPortLabel.BackgroundColor = handles.GREEN_COLOR;
 
    %Close this window and open the main GUI
    
        %Stop the Serial Port Explor Timer
        stop(handles.t_ComExplore);
    
    run(handles.MainFile)
    
    
    handles.figure1.Color = handles.WHITE_COLOR;
    handles.BaudRateLabel.BackgroundColor = handles.WHITE_COLOR;
    handles.COMPortLabel.BackgroundColor = handles.WHITE_COLOR;
    
    
    assignin('base', 'SerialHandles', handles);
    
    guidata(hObject, handles);
    close(handles.output);





% --- Executes on button press in DisconnectButton.
function DisconnectButton_Callback(hObject, eventdata, handles)
% hObject    handle to DisconnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Close the Instrument
    if length(instrfind) >0            
        fclose(instrfind);
    end


% --- Executes on selection change in COMList.
function COMList_Callback(hObject, eventdata, handles)
% hObject    handle to COMList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COMList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COMList


% --- Executes during object creation, after setting all properties.
function COMList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COMList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DeviceSearch.
function DeviceSearch_Callback(hObject, eventdata, handles)
% hObject    handle to DeviceSearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Start the Search Timer again
    if strcmp(handles.t_ComExplore.running, 'off')
        start(handles.t_ComExplore);
    end
    handles.spinnerObj.spinner.start;


% --- Executes on selection change in BaudRate.
function BaudRate_Callback(hObject, eventdata, handles)
% hObject    handle to BaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BaudRate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BaudRate


% --- Executes during object creation, after setting all properties.
function BaudRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ConnectButton.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ConnectButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function ConnectButton_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ConnectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

assignin('base', 'SerialHandles', handles);
delete(hObject);


% --- Executes on selection change in ConnectionType.
function ConnectionType_Callback(hObject, eventdata, handles)
% hObject    handle to ConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ConnectionType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ConnectionType


% --- Executes during object creation, after setting all properties.
function ConnectionType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ConnectionType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
