function varargout = MainApp_LoggerOnly(varargin)
% MAINAPP_LOGGERONLY MATLAB code for MainApp_LoggerOnly.fig
%      MAINAPP_LOGGERONLY, by itself, creates a new MAINAPP_LOGGERONLY or raises the existing
%      singleton*.
%
%      H = MAINAPP_LOGGERONLY returns the handle to a new MAINAPP_LOGGERONLY or the handle to
%      the existing singleton*.
%
%      MAINAPP_LOGGERONLY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINAPP_LOGGERONLY.M with the given input arguments.
%
%      MAINAPP_LOGGERONLY('Property','Value',...) creates a new MAINAPP_LOGGERONLY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainApp_LoggerOnly_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainApp_LoggerOnly_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainApp_LoggerOnly

% Last Modified by GUIDE v2.5 16-Oct-2017 23:29:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainApp_LoggerOnly_OpeningFcn, ...
                   'gui_OutputFcn',  @MainApp_LoggerOnly_OutputFcn, ...
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


% --- Executes just before MainApp_LoggerOnly is made visible.
function MainApp_LoggerOnly_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainApp_LoggerOnly (see VARARGIN)

% handles.SerialHandles=evalin('base','SerialHandles')
% Choose default command line output for MainApp_LoggerOnly
handles.output = hObject;
handles.MainFile = mfilename;

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
        handles.MaximumNumPoints=300;
        handles.Intensity1=[];
        handles.Intensity0=[];
        handles.timeVec=[];
        
        mkdir('data');
        
        dateStr=datestr(now,'yyyy_mm_dd---HH,MM,SS');
        filename = ['LOG---',dateStr,'.txt'];
        
        handles.dataFileDir=['data/',dateStr,'/'];
        mkdir(handles.dataFileDir);
        
        handles.logFileID = fopen([handles.dataFileDir,filename],'a');
        handles.logFileOpen=0;
        
        
        %Set Up the graph

            axes(handles.MainGraph1);
            hold on
            
            for i=1:8     
                handles.lines1(i) = plot(0,0);
                handles.lines1(i).LineWidth=1.5;
            end
            ylabel('Visible Light (bits)');
            
            axes(handles.MainGraph0);
            hold on
            for i=1:8
                handles.lines0(i) = plot(0,0);
                handles.lines0(i).LineWidth=1.5;
            end
            xlabel('Time')
            ylabel('InfraRed Light (bits)');
            
            
        
        
        handles = setPanelColor( handles,handles.StartStop,false );


        handles = DuplicateSensorButtons(hObject, eventdata, handles);
        
        %Set the colors
            sensorNum=1
            handles = setControlColor( handles,sensorNum,true );

        %Send Serial Data
            handles.States(sensorNum+1,:)= [1, 6];
            handles.Graphs = find(handles.States(:,1)==1);
            disp(handles.States);
            disp(handles.Graphs);

        assignin('base', 'handles', struct());
        assignin('base', 'handles', handles);
        % Update handles structure

            %handles.s.BytesAvailableFcn = {@serialEventHandler,handles.output};


          %warndlg('Hey Daniel, to view the data from the 1 sensor that is turned on, "Turn On" Channel 1');  
    end
    assignin('base', 'handles', handles);
guidata(hObject, handles)



% UIWAIT makes MainApp_LoggerOnly wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainApp_LoggerOnly_OutputFcn(hObject, eventdata, handles) 
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
    
    handles.States(j,:)= [0, mult];
    handles.Graphs = find(handles.States(:,1)==1);
    disp(handles.Graphs);
    

pause(0.3);

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
    mult = handles.multiplierEnums(val)
    
    handles.States(sensorNum+1,:)= [1, mult];
    handles.Graphs = find(handles.States(:,1)==1);
    disp(handles.States);
    disp(handles.Graphs);

guidata(handles.figure1, handles);

pause(0.3);




% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles)
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StartButton

               
        %Set the Save Filename
            filename = ['DATA---',datestr(now,'yyyy_mm_dd---HH,MM,SS'),'.txt'];
            handles.dataFileID = fopen([handles.dataFileDir,filename],'a');
            handles.dataFileOpen=1;
        
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
        guidata(handles.figure1, handles);
        
            pause(0.3);   
            
            
         
         

    
   




% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)
% hObject    handle to StopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopButton

                
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
            
            handles.s.BytesAvailableFcn='';
            %handles.s.BytesAvailableFcn = {@serialEventHandlerBlank,handles.output};
            
            guidata(hObject, handles);
            pause(0.3);
            
            
       if handles.dataFileOpen
            fclose(handles.dataFileID);
            handles.dataFileOpen=0;
       end
            
            
     handles.SDIndicator.BackgroundColor=hex2rgb(handles.colors.DarkGray);
        
        guidata(hObject, handles);
        
   





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
    
        handles.MaximumNumPoints=str2num(str);
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



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
 evalin( 'base', 'clear(''s_save'')' );
 fclose('all');
instrreset

delete(hObject);




function serialEventHandlerBlank(hObject, eventdata, mainFigure)

handles=guidata(mainFigure);


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
            fprintf(handles.s,'%c',[buff{1}(2:end)]);
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
            
            disp(handles.Graphs)
            
           

    else


    end
    
    
    guidata(handles.figure1, handles);
assignin('base', 'handles', handles);
    
end



end





function serialEventHandler(hObject, eventdata, mainFigure)

handles=guidata(mainFigure);

%disp('THis is the main Handler')
buff = getSerialBuffer(handles.s)
%assignin('base', 'buff', buff);

%disp(handles.Graphs)

    if length(buff)<1
        return
    end

    if contains(buff{1},'ON')
        return
    end

    

for i=1:length(buff)
    line = buff{i};
    
    if handles.dataFileOpen
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
        Intensity1 = valNums(3:2:end);
        Intensity0 = valNums(4:2:end);
        

        graphs=handles.Graphs;
        
            handles.Intensity1(end+1,:)=Intensity1;
            handles.Intensity0(end+1,:)=Intensity0;
            handles.timeVec(end+1) = time;
            
            disp(handles.Intensity1)
            disp(handles.timeVec)
            
        if  size(handles.Intensity1,1)>= handles.MaximumNumPoints
            handles.Intensity1=handles.Intensity1(2:end,:);
            handles.Intensity0=handles.Intensity0(2:end,:);
            handles.timeVec=handles.timeVec(2:end);

        end
           
        
        for j=1:length(Intensity1)
            handles.lines1(j).XData = handles.timeVec;
            handles.lines1(j).YData = handles.Intensity1(:,j)';
            handles.lines0(j).XData = handles.timeVec;
            handles.lines0(j).YData = handles.Intensity0(:,j)';
            drawnow;

        end
        
        
        
        if length(handles.timeVec)>=2       
        handles.MainGraph1.XLim = [min(handles.timeVec),max(handles.timeVec)];
        handles.MainGraph0.XLim = [min(handles.timeVec),max(handles.timeVec)];
        axis 'auto y'
        end
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
            handles.Intensity1=[];
            handles.Intensity2=[];
            handles.timeVec=[];
 end
    
    


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

fprintf(handles.s,'%c','RS01------');














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
dash='-------';
dash(1:length(str))=str;

fprintf(handles.s,'%c',['SDN',dash]);


guidata(handles.output, handles);
