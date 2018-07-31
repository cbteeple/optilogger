function spinnerObj = createSpinner(inText,figHand,location)


try
    % R2010a and newer
    iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
    iconsSizeEnums = javaMethod('values',iconsClassName);
    SIZE_32x32 = iconsSizeEnums(4);  % (1) = 16x16,  (2) = 32x32
    spinner = com.mathworks.widgets.BusyAffordance(SIZE_32x32, inText)% icon, label
catch
    % R2009b and earlier
    redColor   = java.awt.Color(1,0,0);
    blackColor = java.awt.Color(0,0,0);
    spinner = com.mathworks.widgets.BusyAffordance(redColor, blackColor);
end
spinner.setPaintsWhenStopped(false);  % default = false
spinner.useWhiteDots(false);         % default = false (true is good for dark backgrounds)

spinnerObj=struct();
spinnerObj.javaObj=javacomponent(spinner.getComponent, location, figHand);
spinnerObj.spinner=spinner;

end