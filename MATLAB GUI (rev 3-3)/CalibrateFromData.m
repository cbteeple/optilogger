
%Get the files you want to use for the calibration. You need 8 in total.
    [files, path] = uigetfile('*.txt','MultiSelect', 'on');

    if ~iscell(files)
        files={files};

    end
 

%Get all of the calibration values from the data files
     calMean=zeros(1,length(files));
     for i= 1:length(files)
        %Get all of the data saved in that file
            DATA=dlmread([path,files{i}],'\t');
        %Find the mean
            calMean(i)=mean(DATA(:,3));  

     end
 
 
 fid=fopen('settings/CurrentCalibration.txt','w+');
 for j=1:length(multipliers)
    fprintf(fid,'%f',calMean(j));
    fprintf(fid,'\r');
 end
 fclose(fid);
 

 
 