function setStateButtons(handles)

on = handles.States(:,1);
mult = handles.States(:,2);


for i = 1:length(handles.sensorControls) 
    %Set the colors
        handles = setControlColor( handles,i-1,on(i) );

    %Set the Buttons
        childTags = getChildTags( handles.sensorControls{i},...
                {'SensorOn';'SensorOff';'sensorMultiplier'} );
        hands=childTags.hand;
        hands(1).Value=on(i)>0;
        hands(2).Value=~on(i);
        
        hands(3).Value = find(handles.multiplierEnums==mult(i));

end