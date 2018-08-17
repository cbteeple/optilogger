#include <stdlib.h>
#include <EEPROMAnything.h>
#include <Wire.h>

//#include <SD.h>
//#include <SoftwareSerial.h>

#include "VarDefs.h"
#include "FunctionDefs.h"


CustomFuns::CustomFuns();


//SD
    void CustomFuns::DataColectionOff(int silent){
      if (!silent){
          Serial.println("Collect Data: Turn Off");
      }
            
      if (silent!=2){
          dataOn=0;
      }
    }
    
    void CustomFuns::DataColectionOn(int silent){
        if (!silent){
            Serial.println("Collect Data: Turn On");
        }
        dataOn=1;
    }


//LEDs
  void CustomFuns::InitiatlizeLEDs(){
        for(int p=0; p<ledCnt; p++){
          pinMode(ledPins[p], OUTPUT); // Set the mode to OUTPUT
          digitalWrite(ledPins[p], LOW);
          ledOn[p]=0;
        }
    }

  void CustomFuns::LEDBounce(){
      digitalWrite(ledPins[0], HIGH);
      delay(50);
      for(int p=1; p<ledCnt; p++){
        digitalWrite(ledPins[p], HIGH);
        digitalWrite(ledPins[p-1], LOW);
        delay(50);
        }
      
      for(int p=ledCnt-2; p>=0; p--){
        digitalWrite(ledPins[p], HIGH);
        digitalWrite(ledPins[p+1], LOW);
        delay(50);
        }
      
    
    }


  void CustomFuns::LEDClear(){
      for(int p=0; p<ledCnt; p++){
        digitalWrite(ledPins[p], LOW);
      }

    }

  void CustomFuns::LEDAll(){
      for(int p=0; p<ledCnt; p++){
        digitalWrite(ledPins[p], HIGH);
      }

    }
    


//SD
    void CustomFuns::getFileName(){
       EEPROM_readAnything(fileNumber_Start, fileNumber);
       EEPROM_writeAnything(fileNumber_Start, fileNumber+1);
       String fileNumberStr = String(fileNumber);
       fileNumberStr.concat(".txt");
       fileName = fileNumberStr;
      
       }

    void CustomFuns::setFileName(int desiredNum){
      EEPROM_writeAnything(fileNumber_Start, desiredNum-1);
      String fileNumberStr = String(desiredNum-1);
       fileNumberStr.concat(".txt");
       fileName = fileNumberStr;
      }



//RESET
    void CustomFuns::ResetArduino(){
        Serial.end();
        delay(10);
        //digitalWrite(pinReset,LOW);
        delay(100);
        Serial.begin(9600);
      }



//EEPROM
    void CustomFuns::ReadLightSensorSettings(){
        int num1 = EEPROM_readAnything(lightSensorActive_Start, lightSensorActive);
        int num2 = EEPROM_readAnything(lightSensorSettings_Start, lightSensorSettings);
        
        for(int sensorNum=0; sensorNum < numberOfSensors ; sensorNum++){
            SetLightSensorSettings(sensorNum); 
        }
        
        SensorStateDisp();
      }

    void CustomFuns::SaveLightSensorSettings(){
        EEPROM_writeAnything(lightSensorActive_Start, lightSensorActive);
        EEPROM_writeAnything(lightSensorSettings_Start, lightSensorSettings);
        
        for(int sensorNum=0; sensorNum < numberOfSensors ; sensorNum++){
            SetLightSensorSettings(sensorNum); 
        }       
         
        SensorStateDisp();
        
      }


//LIGHT SENSORS

    void CustomFuns::InitializeSensors(void){
        //Initialize the vectors
            for (int i=0; i<numberOfSensors; i++){
                lightSensorActive[i]=0;
                lightSensorSettings[i] = 1;
                reading01[i]=0;
                reading23[i]=0;
            }
        //Start Wire and Serial Coms
            Wire.begin();                // join i2c bus (address optional for master)
            Wire.setClock(400000L);

      }


    void CustomFuns::SensorStateDisp(){
          for (int i=0; i< numberOfSensors; i++){
              Serial.print(lightSensorActive[i]);
              Serial.print('\t');
              Serial.println(byte(lightSensorSettings[i] >> 2));       
          }
      }


    void CustomFuns::ModifyLightSensorSettings(String inDataStr){        
        Serial.print("Modifying Sensor Settings for ");
        Serial.println(inDataStr);
        

        int len= inDataStr.length();


        if (inDataStr.substring(3,6)=="CLR"){
            //turn off all sensors.
            for (int i=0; i<numberOfSensors; i++){ 
                lightSensorActive[i]=0;
                SetLightSensorSettings(i);         
            }
            
            if (inDataStr.substring(6)=="ALL"){
                for (int i=0; i<numberOfSensors; i++){ 
                    lightSensorSettings[i]=1;
                    SetLightSensorSettings(i);         
                }
          }
        }

        else{
        
            int senseNum = inDataStr.substring(3,4).toInt();
            //Serial.print("Sensor Number: ");
            //Serial.print(senseNum);
            //Serial.print('\t');
            
            if (len>=5){
   
                    int senseON = inDataStr.substring(4,5).toInt();
                    lightSensorActive[senseNum] = senseON;
                              
            }
            if (len==6){
                int senseSet = inDataStr.substring(5,6).toInt();
                //Serial.print("Setting: ");
                //Serial.println(senseSet);
                lightSensorSettings[senseNum] = byte((senseSet << 2) | 1);
               
                
            }           
                
    
            SetLightSensorSettings(senseNum);
            SensorStateDisp();
         }
      }
    




    void CustomFuns::SetLightSensorSettings(int sensorNum){
        //Set the LED
            digitalWrite(ledPins[sensorNum], lightSensorActive[sensorNum]); 

        
        //Set the Muliplexer to the correct channel
                delay(10);
                Wire.beginTransmission(Mux_Addr); // transmit to device
                Wire.write(1 << sensorNum);      
                Wire.endTransmission();      // stop transmitting
                delay(10);


            //Send settings to the light sensors
                if (lightSensorActive[sensorNum]){
                    //Set the control register to the correct muliplier
                        //delay(10);
                        Wire.beginTransmission(Slave_Addr); // transmit to device
                        Wire.write(byte(0x80));      
                        Wire.write(lightSensorSettings[sensorNum]);
                        Wire.endTransmission();      // stop transmitting
                        //delay(10);
                  
                  
                    //Set up the Sample Rate and Integration Time
                        Wire.beginTransmission(Slave_Addr); // transmit to device
                        Wire.write(byte(0x85));      
                        Wire.write(byte(B00001000));
                        Wire.endTransmission();      // stop transmitting
          
                }
      
                else{
                    //Set the control register OFF
                        //delay(10);
                        Wire.beginTransmission(Slave_Addr); // transmit to device
                        Wire.write(byte(0x80));      
                        Wire.write(byte(0));
                        Wire.endTransmission();      // stop transmitting
                        //delay(10);
                }

    }





    void CustomFuns::AquireData(){

        long t_out=millis();
        if (pressureOn){
          pressure= CustomFuns::GetPressureData();
        }
        
        for(int sensorNum=0; sensorNum < numberOfSensors; sensorNum++){
              
            if (lightSensorActive[sensorNum]){

                //Set the Muliplexer to the correct channel
                    //delay(10);
                    Wire.beginTransmission(Mux_Addr); // transmit to device
                    Wire.write(1 << sensorNum);      
                    Wire.endTransmission();      // stop transmitting
                    //delay(10);


                // Set up the Sensor reading settings       
                    Wire.beginTransmission(Slave_Addr); // transmit to device
                    Wire.write(byte(0x88));   
                    Wire.endTransmission();      // stop transmitting   
                    
                    Wire.requestFrom(Slave_Addr, 4, true);    // request 2 bytes from slave device #112
                    reading0 = Wire.read();
                    reading1 = Wire.read();
                    reading2 = Wire.read();
                    reading3 = Wire.read();
        
                //Combine High and Low bits    
                    reading01[sensorNum]= reading1<<8 | reading0; 
                    reading23[sensorNum]= reading3<<8 | reading2;

            }
            }
            
        //Save Readings               
                if(Serial){
                  Serial.print(1);   // print the reading
                  Serial.print('\t');   // print the reading
                }
              
                
        //Send Them Out
            if(Serial){
                Serial.print(t_out);   // print the reading
                for (int i=0; i<numberOfSensors; i++){
    
                    if(lightSensorActive[i]){
                        Serial.print('\t');
                        Serial.print(reading01[i]);
                        Serial.print('\t');
                        Serial.print(reading23[i]);
                 }
                }  

              if (pressureOn){
                Serial.print('\t');
                Serial.print(pressure);
              }

              Serial.print('\n'); //End the line
            }
      
      
      }




void CustomFuns::UpdateFreq(String command){
  desiredFreq = command.substring(4).toFloat();
  desiredLoopTime = int((1/desiredFreq)*1000);
  
  if (!dataOn){
    Serial.print("New Frequency: ");
    Serial.println(desiredFreq);
  }  
}





//ANALOG PRESSURE GAUGE
    float CustomFuns::GetPressureData(){
        return analogRead(pressurePin)*5.0 / 1023.0*14.5038;
    }



//INTERRUPTS/TIMER


    void CustomFuns::TimerSetup(){
      //Set Timer 1 interrupt
            //Set up the timer
                //General Setup
                    TCCR1A = 0;// set entire TCCR1A register to 0
                    TCCR1B = 0;// same for TCCR1B
                    TCNT1  = 0;//initialize counter value to 0
                // set compare match register for 1hz increments
                    OCR1A = outputCompare;     // = (8*10^6) / (10*128) -1 (must be <65536) NEW CALC FOR 8 MHZ CHIP
                // Set CS12 and CS10 bits for 1024 prescaler
                    TCCR1B |= 0x00; //(1 << CS12) | (1 << CS10);  
                // turn on CTC mode
                    //TCCR1B |= (1 << WGM12);
            //Enable timer compare interrupt
                TIMSK1 |= (1 << OCIE1A);
       
      }

    void CustomFuns::TimerMath(float desiredFreq){
        //Decide what the prescale should be
    
            prescaleBin = float(clockFreq)/(float(counterRes));
            
            if (desiredFreq <= clockFreq && desiredFreq >= prescaleBin/1)
              clockInputSelect=1;
            else if (desiredFreq < prescaleBin/1 && desiredFreq >= prescaleBin/8)
              clockInputSelect=2;
            else if (desiredFreq < prescaleBin/8 && desiredFreq >= prescaleBin/64)
              clockInputSelect=3;
            else if (desiredFreq < prescaleBin/64 && desiredFreq >= prescaleBin/256)
              clockInputSelect=4;
            else if (desiredFreq < prescaleBin/256 && desiredFreq >= prescaleBin/1028)
              clockInputSelect=5;
            else{
              clockInputSelect=0;
              }    

            //Serial.print("Clock Input Select: ");
            //Serial.println(clockInputSelect);


              
        //Determine the Prescale Exponent based on the clock input mode
            if(clockInputSelect<=3){
              prescaleExp = (clockInputSelect-1)*3;
              }
            else if(clockInputSelect>3 && clockInputSelect<=5){
              prescaleExp = (clockInputSelect)*2;
              }

           // Serial.print("Prescale Exponent: ");
           // Serial.println(prescaleExp);

        //Calculate the output compare values via this formula:
            //  m = (f / (p*f_des)) - 1
            //  where p is the prescaler,
            //        f_des is the desired frequency,
              
            outputCompare = (clockFreq/((pow(2,prescaleExp)*desiredFreq)))-1;

            //Serial.print("Output Compare Value: ");
            //Serial.println(outputCompare);
      
      }
