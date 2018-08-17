//Include all the function and libraries we need
  #include "VarDefs.h"
  #include "FunctionDefs.h"

CustomFuns myFuns;

//Pin to use for the trigger interrupt
const byte interruptPin = 2;

//Program flow control
boolean getNewSample=0;
boolean triggerMode = 0;

//Timing Vars
unsigned long timeCurr=0;
unsigned long timeLast=0;

//_______________________________________________________________
void setup() {
  //SERIAL
  Serial.begin(115200);
  Serial.setTimeout(20);

  //TRIGGER INTERRUPT
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), triggerISR, RISING);

  //LEDs
  myFuns.InitiatlizeLEDs(); //Set all the LED pins
  myFuns.LEDBounce(); //Do a cute bouncing animation
  myFuns.LEDClear(); //Turn off all of th LEDs
  
  //SENSORS
  myFuns.InitializeSensors(); //Turn all of the light sensors ON
}



//_______________________________________________________________
void loop() {
  //Do some stuff if this is the first iteration of the loop.
  //  This could probably be moved to the "setup" function,
  //  but it's left over from when I was using a different MCU
  if (firstCall){
    firstCallFuns();
    firstCall=0;
  }

  //Read Serial data and process commands if they exist
  readSerial();

  //If we are supposed to be getting data...
  if (dataOn){
    //If we are in trigger mode:
    if (triggerMode){
      //If we are supposed to get a new sample
      if (getNewSample){
        //Get a new sample, then clear the flag
        myFuns.AquireData();
        getNewSample=0;
      }
    }
    //If we are not in trigger mode, then we are in sampling mode:
    else{
      //If it's time to get a new sample...
      timeCurr=millis();  
      if (timeCurr-timeLast>= desiredLoopTime){
        //Get a new sample, then update the value of the last time in prep for the next sample
        myFuns.AquireData();
        timeLast=timeCurr;  
      }
    }
  }

} //End the main loop




//_______________________________________________________________
//FIRST CALL FUNCTIONS
void firstCallFuns(){
  Serial.println("Starting Program");   // print the reading

  //Initialize the settings arrays
  for(int sensorNum=0; sensorNum < numberOfSensors ; sensorNum++){
      myFuns.SetLightSensorSettings(sensorNum); 
  }

  Serial.flush();
  Serial.println("firstCall=0");
  //Serial.println("firstCall=0");
  myFuns.LEDBounce();
  myFuns.LEDClear();
  myFuns.LEDAll();  
  
}



//_______________________________________________________________
//TRIGGER FUNCTIONS

//Interrupt service routine for external triggering
//  (Always runs, even if you're not using it. It's speedy so that's fine)
void triggerISR(){
  getNewSample=1;
}



//_______________________________________________________________
//SERIAL CONTROL FUNCTIONS

//Read serial data from the buffer, then process the revieved commands
void readSerial(){
  while (Serial.available()>0){
    String command = Serial.readStringUntil('\n');
    processCommand(command);
  }
}


//Process commands from serial
void processCommand(String command){
    //Mirror the input
    Serial.println(command);   
    command.replace("-", ""); //Left over from an older-style implementation. Likely unnessecary now.

    if(command.startsWith("OFF")){
      Serial.println("Turn OFF Data Collection");
      myFuns.DataColectionOff(0);                 
    }
    else if (command.startsWith("ON")){
      Serial.println("Turn ON Data Collection");
      myFuns.DataColectionOn(0);
    }
    else if (command.startsWith("RS01")){
      Serial.println("Reset SD Card");
    }
    else if (command.startsWith("RS00")){
      Serial.println("Reset Device");
      myFuns.DataColectionOff(0);
      myFuns.ResetArduino();
    }
    else if (command.startsWith("SAVE")){
      Serial.println("Save Settings to EEPORM");
      myFuns.SaveLightSensorSettings();
    }
    else if (command.startsWith("READ")){
      Serial.println("READ Settings from EEPORM");
      myFuns.ReadLightSensorSettings();
    }
    else if (command.startsWith("MOD")){
      //Serial.println("Modify sensor settings");
      myFuns.ModifyLightSensorSettings(command);
    }    
    else if (command.startsWith("DISP")){
      Serial.println("Current Settings");
      myFuns.SensorStateDisp();
    }

    else if (command.startsWith("RDFREQ")){
        Serial.println(desiredFreq);
    }

    else if (command.startsWith("TRIG")){
      if (command.substring(4,6)=="ON"){
        triggerMode=1;
      }
      else{
        triggerMode=0;
      }
    }   
    else if (command.startsWith("FREQ")){
      myFuns.UpdateFreq(command);
    }
    else{
      Serial.println("Unrecognized Command");
    }

  
}







