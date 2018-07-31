function handles = setControlColor( handles,sensor,on )
%SetControlColor Summary of this function goes here
%   Detailed explanation goes here

if on
    newcolorLight=handles.colors.GraphLight{sensor+1};
    newcolorDark=handles.colors.GraphDark{sensor+1};
    newTextColor=handles.colors.Black;
    
    handles.lines1(sensor+1).Visible='on';
    handles.lines0(sensor+1).Visible='on';
   
else
    newcolorLight=handles.colors.LightGray;
    newcolorDark=handles.colors.DarkGray;
    newTextColor=handles.colors.DarkGray;
    
    handles.lines1(sensor+1).Visible='off';
    handles.lines0(sensor+1).Visible='off';
end


handles.lines1(sensor+1).Color = hex2rgb(handles.colors.GraphDark{sensor+1});
handles.lines0(sensor+1).Color = hex2rgb(handles.colors.GraphDark{sensor+1});





handles.sensorControls{sensor+1}.BackgroundColor = hex2rgb(newcolorLight);
%handles.sensorControls{sensor+1}.HighlightColor = hex2rgb(newcolorLight);
handles.sensorControls{sensor+1}.ShadowColor = hex2rgb(newcolorDark);

handles.sensorControls{sensor+1}.Children(1).BackgroundColor = hex2rgb(newcolorLight);
handles.sensorControls{sensor+1}.Children(1).ForegroundColor = hex2rgb(newTextColor);

handles.sensorControls{sensor+1}.Children(end).BackgroundColor = hex2rgb(newcolorLight);



end

