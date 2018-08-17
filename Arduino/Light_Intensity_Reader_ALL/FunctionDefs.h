#ifndef FunctionDefs_h
#define FunctionDefs_h

#include "Arduino.h"


class CustomFuns
{
    public:
    	 CustomFuns(){};
    		
    		//General
    			void DataColectionOff(int);
    			void DataColectionOn(int);

        //LEDs
          void InitiatlizeLEDs();
          void LEDBounce();
          void LEDClear();
          void LEDAll();
          
    		//SD
    			void getFileName();
    			void setFileName(int);
    
    		//RESET
    			void ResetArduino();
    
    		//EEPROM
    			void ReadLightSensorSettings();
    			void SaveLightSensorSettings();
    
    		//LIGHT SENSORS
          void InitializeSensors(void);
    			void SensorStateDisp();
    			void ModifyLightSensorSettings(String);
    			void SetLightSensorSettings(int);
          void AquireData();
          void UpdateFreq(String);

        //ANALOG PRESSURE GAUGE
          float GetPressureData();

    		//INTERRUPTS/TIMER
    			void TimerSetup();
    			void TimerMath(float);

    private:
};

#endif
