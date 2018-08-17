function varargout = MainApp(varargin)
% MAINAPP MATLAB code for MainApp.fig
%      MAINAPP, by itself, creates a new MAINAPP or raises the existing
%      singleton*.
%
%      H = MAINAPP returns the handle to a new MAINAPP or the handle to
%      the existing singleton*.
%
%      MAINAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINAPP.M with the given input arguments.
%
%      MAINAPP('Property','Value',...) creates a new MAINAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainApp

% Last Modified by GUIDE v2.5 11-Jul-2018 17:49:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainApp_OpeningFcn, ...
                   'gui_OutputFcn',  @MainApp_OutputFcn, ...
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


% --- Executes just before MainApp is made visible.
function MainApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainApp (see VARARGIN)

% handles.SerialHandles=evalin('base','SerialHandles')
% Choose default command line output for MainApp
handles.output = hObject;
handles.MainFile = mfilename;

%Switch the folder
    fullpath=mfilename('fullpath');
    
    
    
    idx=strfind(fullpath,filesep);
    currPath=fullpath(1:idx(end))
    cd(currPath)

  ise = evalin( 'base', 'exist(''s_save'',''var'') == 1' );
    if ~ise %If the serial device has not been set up, run the 
        handles.closeFigure = true;
        
        assignin('base', 'handles', handles);
        SerialSetup; 
    else
             
        evalin('base','s_save');

        pause(1);

        handles.s=evalin('base','s_save');

            %Add all all of the subfolders of the App's folder to the MATLAB path.
                MyPath = pwd;
                addpath(genpath(MyPath), '-end');

        %CALIBRATION <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            %handles.calibration=dlmread('settings/CurrentCalibration.txt');
            handles.calibration = ones(1,8);% [750, 450, 9226, 1440, 7000, 4000, 1250, 950];
        %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        
        handles.colors=getColors();
        handles.DataCollection = 0;
        handles.freq = 10;
        handles.multiplierEnums = [0,1,2,3,6,7];
        handles.States = [zeros(8,1), ones(8,1)];
        handles.Graphs = find(handles.States(:,1)==1);
        handles.dataFileID=0;
        handles.dataFileOpen=0;
        handles.logFileOpen=0;
        handles.clearGraphEveryTime=1;
        handles.pressureOn=handles.pressureOnButton.Value;
                
        mkdir('data');
        
        dateStr=datestr(now,'yyyy_mm_dd---HH,MM,SS');
        filename = ['LOG---',dateStr,'.txt'];
        
        handles.dataFileDir=fullfile('data',dateStr);
        mkdir(handles.dataFileDir);
        
        handles.logFileID = fopen(fullfile(handles.dataFileDir,filename),'a');
        handles.logFileOpen=0;
        
        
        %Set Up the graph
            axes(handles.MainGraph1);
            hold on
            
            for i=1:8     
                handles.lines1(i) = animatedline();
                handles.lines1(i).LineWidth=1.5;
                handles.lines1(i).MaximumNumPoints=300;
            end
            ylabel('Visible Light (scaled)');
            xlabel('Time (minutes)')
            handles.MainGraph1.Color='none';
            
            axes(handles.MainGraph0);
            hold on
            for i=1:8
                handles.lines0(i) = animatedline();
                handles.lines0(i).LineWidth=2;
                handles.lines0(i).MaximumNumPoints=300;
            end
            xlabel('Time')
            ylabel('InfraRed Light (scaled)');
            
            axes(handles.pressureAxis);
                handles.pressureLine = animatedline();
                handles.pressureLine.Color='b';
                handles.pressureLine.LineWidth=0.75;
                handles.pressureLine.MaximumNumPoints=300;
            handles.pressureAxis.Color='none';
            handles.pressureAxis.XColor='none';
            handles.pressureAxis.YAxisLocation='right';
            handles.pressureAxis.YLim = [0,35];
            handles.pressureAxis.YColor='b';
            ylabel('Pressure (psi)');
            
            
            
        
        
        handles = setPanelColor( handles,handles.StartStop,false );


        handles = DuplicateSensorButtons(hObject, eventdata, handles);

        assignin('base', 'handles', struct());
        assignin('base', 'handles', handles);
        % Update handles structure

            handles.s.BytesAvailableFcn = {@serialEventHandlerBlank,handles.output};


            %handles.MainGraph1.YLim=[0,1];
    end
    flushinput(handles.s);
    assignin('base', 'handles', handles);
guidata(hObject, handles)



% UIWAIT makes MainApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainApp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if (isfield(handles,'closeFigure') && handles.closeFigure)
      figure1_CloseRequestFcn(hObject, eventdata, handles)
end


% --- Executes on selection change in sensorMultiplier.
function sensorMultiplier_Callback(hObject, eventdata, handles)
% hObject    handle to sensorMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sensorMultiplier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sensorMultiplier

    par=eventdata.Source.Parent;
    tag=par.Tag();  
        
    idx=regexp(tag,'[\d]');
    sensorNum=str2num(tag(idx));

%Send Serial Data
    val = get(hObject,'Value');
    mult = handles.multiplierEnums(val);
    
    outStr='MOD';
    outStr(4) = num2str(sensorNum);
    outStr(5) = num2str(handles.States(sensorNum+1,1));
    outStr(6) = num2str(mult);

fprintf(handles.s,'%c',outStr);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function sensorMultiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensorMultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sensor1_toggle.
function sensor1_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to sensor1_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sensor1_toggle


% --- Executes on button press in SensorOff.
function SensorOff_Callback(hObject, eventdata, handles)
% hObject    handle to SensorOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Set the colors
    par=eventdata.Source.Parent;
    tag=par.Tag();  
        
    idx=regexp(tag,'[\d]');
    sensorNum=str2num(tag(idx));
    handles = setControlColor( handles,sensorNum,false );


%Send Serial Data
    childTags = getChildTags(eventdata.Source.Parent, {'sensorMultiplier'});
    multHand=childTags.hand(1);
    val = multHand.Value;
    mult = handles.multiplierEnums(val);
    
    outStr='MOD';
    outStr(4) = num2str(sensorNum);
    outStr(5) = num2str(0);
    outStr(6) = num2str(mult);

fprintf(handles.s,'%s\n',outStr);

%pause(0.3);

guidata(hObject, handles);


% --- Executes on button press in SensorOn.
function SensorOn_Callback(hObject, eventdata, handles)
% hObject    handle to SensorOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SensorOn

%Set the colors
    par=eventdata.Source.Parent;
    tag=par.Tag();  
    
    idx=regexp(tag,'[\d]');
    sensorNum=str2num(tag(idx));
    handles = setControlColor( handles,sensorNum,true );

%Send Serial Data
    childTags = getChildTags(eventdata.Source.Parent, {'sensorMultiplier'});
    multHand=childTags.hand(1);
    val = multHand.Value;
    mult = handles.multiplierEnums(val);
    
    outStr='MOD';
    outStr(4) = num2str(sensorNum);
    outStr(5) = num2str(1);
    outStr(6) = num2str(mult);
    outStr

fprintf(handles.s,'%s\n',outStr);
guidata(handles.figure1, handles);

%pause(0.3);




% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StartButton


    allow=~handles.DataCollection | ~handles.preventDuplicates.Value;
    
    if allow
               
        %Set the Save Filename
            filename = ['DATA---',datestr(now,'yyyy_mm_dd---HH,MM,SS'),'.txt'];
            handles.dataFileID = fopen(fullfile(handles.dataFileDir,filename),'a');
            handles.dataFileOpen=1;
            disp(['Starting Save in: ',filename]);
        
        %Clear all the data in the graphs
        if handles.clearGraphEveryTime
            ClearAll_Callback(hObject, eventdata, handles);
        end
        
        %Set the Color and Labels of the panel
            handles = setPanelColor( handles,eventdata.Source.Parent,true );
            handles.StartButton.String='Running';
            handles.StopButton.String='Stop';
            disp('Data Collection STARTED');
            handles.DataCollection=1;
        
        
        %Disable the Sensor Settings Buttons
            for i = 1:length(handles.sensorControls)
                childTags = getChildTags( handles.sensorControls{i},...
                            {'SensorOn';'SensorOff';'sensorMultiplier'} );
                hands=childTags.hand;
                hands(1).Enable='off';
                hands(2).Enable='off';
                hands(3).Enable='off';
            end
        %Disable the rest of the buttons 
            handles.SendFreq.Enable = 'off';
            handles.FreqBox.Enable = 'off';
            handles.ReadStates.Enable = 'off';
            handles.SaveStates.Enable = 'off';
            
        
        guidata(handles.figure1, handles);
            
         
        %Send Serial Command
        flushinput(handles.s);
        handles.s.BytesAvailableFcn = {@serialEventHandler,handles.output};
        
        
        fprintf(handles.s,'%s\n','ON');
            pause(0.3);   
             
            
         
        guidata(handles.figure1, handles);
        disp(handles.dataFileOpen);

    end
   




% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopButton

    allow=handles.DataCollection | ~handles.preventDuplicates.Value;

    if allow
                
        %Set the Color and Labels of the panel
            handles = setPanelColor( handles,eventdata.Source.Parent,false );
            handles.StartButton.String='Start';
            handles.StopButton.String='Stopped';
            disp('Data Collection STOPPED');
            handles.DataCollection=0;

        %Enable the Sensor buttons
            for i = 1:length(handles.sensorControls)
                childTags = getChildTags( handles.sensorControls{i},...
                            {'SensorOn';'SensorOff';'sensorMultiplier'} );
                hands=childTags.hand;
                hands(1).Enable='on';
                hands(2).Enable='on';
                hands(3).Enable='on';
            end
        
        %Enable the rest of the buttons
            handles.SendFreq.Enable = 'on';
            handles.FreqBox.Enable = 'on';
            handles.ReadStates.Enable = 'on';
            handles.SaveStates.Enable = 'on';
        
        guidata(handles.figure1, handles);
        
        %Send Serial Command
            
            handles.s.BytesAvailableFcn = {@serialEventHandlerBlank,handles.output};
            fprintf(handles.s,'%s\n','OFF');
            
            guidata(handles.figure1, handles);
            pause(0.3);
            
            
       if handles.dataFileOpen
            fclose(handles.dataFileID);
            handles.dataFileOpen=0;
       end
            
            
     handles.SDIndicator.BackgroundColor=hex2rgb(handles.colors.DarkGray);
        
        guidata(handles.figure1, handles);
        
    end


% --- Executes on button press in SendFreq.
function SendFreq_Callback(hObject, eventdata, handles)
% hObject    handle to SendFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%FreqBox_Callback(handles.FreqBox, eventdata, handles);



d = 4; %// number of digits

D = 10^(d-ceil(log10(handles.freq)));
y = round(handles.freq*D)/D;


fprintf(handles.s,'%c%f\n','FREQ',y);


guidata(handles.output, handles);







function FreqBox_Callback(hObject, eventdata, handles)
% hObject    handle to FreqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FreqBox as text
%        str2double(get(hObject,'String')) returns contents of FreqBox as a double

str=get(hObject,'String');
if isempty(str2num(str))
    set(hObject,'string',num2str(handles.freq));
    warndlg('Input must be numerical');
elseif str2num(str)>25
    set(hObject,'string',num2str(handles.freq));
    warndlg('Input must be between 0.1 and 25');
elseif str2num(str)<0.1
    set(hObject,'string',num2str(handles.freq));
    warndlg('Input must be between 0.1 and 25');
else
    
    freq=str2num(str);
    d = 4; %// number of digits

    D = 10^(d-ceil(log10(freq)));
    y = round(freq*D)/D;
    
    handles.freq=y;
    set(hObject,'string',num2str(y));
    
end
guidata(handles.output, handles);





% --- Executes during object creation, after setting all properties.
function FreqBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FreqBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









function NumDispPoints_Callback(hObject, eventdata, handles)
% hObject    handle to NumDispPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumDispPoints as text
%        str2double(get(hObject,'String')) returns contents of NumDispPoints as a double

str=get(hObject,'String');
if isempty(str2num(str))
    warndlg('Input must be numerical');
else
    if str2num(str)>10000
        set(hObject,'string','10000');
        warndlg('Input must be between 1 and 10000');
    elseif str2num(str)<1
        set(hObject,'string','1');
        warndlg('Input must be between 1 and 10000');
    else  
    
    end
    
     for i=1:length(handles.lines1)
        handles.lines1(i).MaximumNumPoints=str2num(str);
        handles.lines0(i).MaximumNumPoints=str2num(str);
        handles.pressureLine.MaximumNumPoints=str2num(str);
     end
end


guidata(handles.output, handles);




% --- Executes during object creation, after setting all properties.
function NumDispPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumDispPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getFreq.
function getFreq_Callback(hObject, eventdata, handles)
% hObject    handle to getFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fprintf(handles.s,'%s\n','RDFREQ');











% --- Executes on button press in SaveStates.
function SaveStates_Callback(hObject, eventdata, handles)
% hObject    handle to SaveStates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fprintf(handles.s,'%s\n','SAVE');




% --- Executes on button press in ReadStates.
function ReadStates_Callback(hObject, eventdata, handles)
% hObject    handle to ReadStates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.s,'%s\n','READ');




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
 evalin( 'base', 'clear(''s_save'')' );
 
 fclose('all');
instrreset
rmpath(genpath(pwd), '-end')

delete(hObject);




function serialEventHandlerBlank(hObject, eventdata, mainFigure)

handles=guidata(mainFigure);
disp(handles.dataFileOpen);


pause(0.2);


if handles.s.BytesAvailable
buff = getSerialBuffer(handles.s)

assignin('base', 'buff', buff);

%Save everything in the log file
    timestamp=['=======',datestr(now,'yyyy_mm_dd, HH:MM:SS'),'======='];
    fprintf(handles.logFileID,'%s\r\n','');
    fprintf(handles.logFileID,'%s\r\n','');
    fprintf(handles.logFileID,'%s\r\n',timestamp);
    fprintf(handles.logFileID,'%s\r\n','');
    
    for idx=1:length(buff)
        fprintf(handles.logFileID,'%s',buff{idx});
    end


if ~isempty(buff)
    
    if length(buff)>=2     
        if contains(buff{2},'Unrecognized')
            %fprintf(handles.s,'%c',[buff{1}(2:end)]);
            %fixSerial_Callback(hObject, event, handles);
            return
        end
        
        
        if contains(buff{1},'RDFREQ')
            handles.freq=str2num(buff{2});
            handles.FreqBox.String=num2str(handles.freq);
            handles.FreqBox.BackgroundColor=hex2rgb(handles.colors.LightGreen);
            pause(0.1);
            handles.FreqBox.BackgroundColor=hex2rgb('#FFFFFF');
        end
        
    end
    

    

    %If the we did a READ operation
    if contains(buff{1},'READ') | contains(buff{1},'MOD')
        if length(buff)==2
            disp('buffer=2');
            pause(.2);
            states = getSerialBuffer(handles.s)
            
        else
            states=buff(3:end);
        end
    

        for j = 1:length(states)
            b=states{j};
            vals = strsplit(b(1:end-2),'\t');
            if length(vals)==2
               handles.States(j,:) = [str2num(vals{1}) , str2num(vals{2})];
            end
        end
        
        
        
        handles.Graphs = find(handles.States(:,1)==1);
            setStateButtons(handles);
            
            %disp(handles.Graphs)
            
           

    else


    end
    
    
    guidata(handles.figure1, handles);
assignin('base', 'handles', handles);
    
end



end





function serialEventHandler(hObject, eventdata, mainFigure)

handles=guidata(mainFigure);
disp(handles.dataFileOpen);

%disp('THis is the main Handler')
buff = getSerialBuffer(handles.s);

%disp(handles.Graphs)

    if length(buff)<1
        return
    end

    if contains(buff{1},'ON')
        return
    end

    

for i=1:length(buff)
    line = buff{i};
    
    disp(handles.dataFileOpen)
     if handles.dataFileOpen
%         %disp('PrintingData');
         fprintf(handles.dataFileID,'%s',line);
     end
    vals = strsplit(line(1:end-2),'\t');
    valNums= cell2mat(cellfun(@str2num, vals,'uniformoutput',false));
    axes(handles.MainGraph1);
    
    if length(vals)>2
        
        
        SDState = valNums(1);
        
        if SDState==0
            handles.SDIndicator.BackgroundColor=hex2rgb(handles.colors.LightGreen);
        else
            handles.SDIndicator.BackgroundColor=hex2rgb(handles.colors.LightRed);  
        end
        
        time = valNums(2)/1000/60;
        Intensity1 = valNums(3:2:end-handles.pressureOn);
        %Intensity0 = valNums(4:2:end);
        
    

        graphs=handles.Graphs;
        for j=1:length(Intensity1)   
               addpoints(handles.lines1(graphs(j)), time , Intensity1(j)./handles.calibration(graphs(j))) ;
               %addpoints(handles.lines0(graphs(j)), time , Intensity0(j)) ;
        end
        
        [times,~] = getpoints(handles.lines1(graphs(1)));
        
        if length(times)<2
            times=[0,inf];
        end
        
        handles.MainGraph1.XLim = [min(times),max(times)];
        
        %handles.MainGraph0.XLim = [min(times),max(times)];
        
        
        
       
        if handles.pressureOn
            pressure=valNums(end);
            addpoints(handles.pressureLine, time, pressure);
            handles.pressureAxis.XLim = [min(times),max(times)];
        end
        
        
        %drawnow;
    end
end

assignin('base', 'handles', handles);
guidata(handles.figure1, handles);


% --- Executes on button press in ClearAll.
function ClearAll_Callback(hObject, eventdata, handles)
% hObject    handle to ClearAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 axes(handles.MainGraph1);

 for i=1:length(handles.lines1)
    clearpoints(handles.lines1(i))
    clearpoints(handles.lines0(i))
    
 end
 clearpoints(handles.pressureLine);   
    


% --- Executes on button press in fixSerial.
function fixSerial_Callback(hObject, eventdata, handles)
% hObject    handle to fixSerial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf(handles.s,'%c','-');
guidata(handles.figure1, handles);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

handles.clearGraphEveryTime=get(hObject,'Value');
guidata(handles.figure1, handles);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ResetSD.
function ResetSD_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.s,'%s\n','RS01');














function SDNum_Callback(hObject, eventdata, handles)
% hObject    handle to SDNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SDNum as text
%        str2double(get(hObject,'String')) returns contents of SDNum as a double

str=get(hObject,'String');
if isempty(str2num(str))
    set(hObject,'string','0');
    warndlg('Input must be numerical');
elseif contains(str,'.')
    set(hObject,'string','0');
    warndlg('Input must be an integer');
elseif length(str)>7
    set(hObject,'string',str(1:7));
    warndlg('Input can have no more than 7 digits');
    
end
guidata(handles.output, handles);









% --- Executes during object creation, after setting all properties.
function SDNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SDNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SendSDNum.
function SendSDNum_Callback(hObject, eventdata, handles)
% hObject    handle to SendSDNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


str=get(handles.SDNum,'String');
fprintf(handles.s,'%s\n',['SDN',str]);

guidata(handles.output, handles);


% --- Executes on button press in pressureOnButton.
function pressureOnButton_Callback(hObject, eventdata, handles)
% hObject    handle to pressureOnButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    fprintf(handles.s,'%s\n','PRESON');
else
    fprintf(handles.s,'%s\n','PRESOFF');
end
handles.pressureOn=hObject.Value;
guidata(handles.output, handles);


% --- Executes on button press in triggered.
function triggered_Callback(hObject, eventdata, handles)
% hObject    handle to triggered (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of triggered

if get(hObject,'Value')
    fprintf(handles.s,'%s\n','TRIGON');
else
    fprintf(handles.s,'%s\n','TRIGOFF');
end
