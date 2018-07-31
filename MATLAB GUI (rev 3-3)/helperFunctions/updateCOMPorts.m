function updateCOMPorts(hObject, eventdata, handles)
            %fclose(instrfind)
            p = instrhwinfo('serial');
            
            avail = p.AvailableSerialPorts;
            
            %If there are no ports available, set the appropriate values
            if length(avail)==0
                handles.COMList.String = {'No Ports Available'};
                handles.COMList.Value = 1;
                handles.COMList.ForegroundColor = [1 0 0];
                handles.ConnectButton.Enable = 'off';
                handles.COMStart=0;
                
            else    
                handles.COMList.String = p.AvailableSerialPorts;
                
                handles.COMList.ForegroundColor = [0 0 0];
                handles.ConnectButton.Enable = 'on';
                
            end

                
            
        end