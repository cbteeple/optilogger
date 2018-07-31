function handles = setPanelColor( handles,PanelHand,on )
%SetControlColor Summary of this function goes here
%   Detailed explanation goes here

if isfield(handles, 'preventDuplicates')
    children = {'dataCollectionLabel','preventDuplicates'};
else
    children = {'dataCollectionLabel'};
end
    

childTags = getChildTags( PanelHand, children);

if on
    newcolorLight=handles.colors.LightGreen;
    newcolorDark=handles.colors.DarkGreen;
else
    newcolorLight=handles.colors.LightRed;
    newcolorDark=handles.colors.DarkRed;
end

PanelHand.BackgroundColor = hex2rgb(newcolorLight);
PanelHand.ShadowColor = hex2rgb(newcolorDark);

for i=1:length(childTags.hand)
    childTags.hand(i).BackgroundColor = hex2rgb(newcolorLight);
end

end

