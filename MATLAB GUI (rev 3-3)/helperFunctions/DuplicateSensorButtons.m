function handles = DuplicateSensorButtons(hObject, eventdata, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    numSensors=8;

    %Create all of the rest of the sensor button groups

    handles.sensorControls = {};

    handles.sensorControls{1} = handles.sensor0_group;

    if contains(handles.MainFile,'LoggerOnly')
        callbackOn = @(hObject,eventdata)MainApp_LoggerOnly('SensorOn_Callback',hObject,eventdata,guidata(hObject));
        callbackOff = @(hObject,eventdata)MainApp_LoggerOnly('SensorOff_Callback',hObject,eventdata,guidata(hObject));
    else
        callbackOn = @(hObject,eventdata)MainApp('SensorOn_Callback',hObject,eventdata,guidata(hObject));
        callbackOff = @(hObject,eventdata)MainApp('SensorOff_Callback',hObject,eventdata,guidata(hObject));
    end

    %Get the children
        childTags = getChildTags( handles.sensor0_group,...
                                  {'sensorNumLabel';...
                                  'SensorOn';'SensorOff';...
                                  'sensorMultiplier'} );
        idx=childTags.idx;
        
    %Duplicate Control Groups
        for i=2:numSensors
            
            handles.sensorControls{i}=copyobj(handles.sensor0_group,handles.output);
            handles.sensorControls{i}.Tag = ['sensor',num2str(i-1),'_group'];
            handles.sensorControls{i}.Position = handles.sensorControls{i-1}.Position - [0,4.5,0,0];
            handles.sensorControls{i}.Children(idx(1)).String = num2str(i-1);
            handles.sensorControls{i}.Children(idx(2)).Callback = callbackOn;
            handles.sensorControls{i}.Children(idx(3)).Callback = callbackOff;
            handles.sensorControls{i}.Children(idx(4)).Callback =...
                @(hObject,eventdata)MainApp('sensorMultiplier_Callback',hObject,eventdata,guidata(hObject));
        end

    %Apply Color formatting
        for i=0:numSensors-1
            handles = setControlColor( handles,i,false);
        end

end

