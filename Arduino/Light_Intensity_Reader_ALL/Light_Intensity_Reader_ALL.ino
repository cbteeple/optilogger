//Include all the function and libraries we need
  #include "VarDefs.h"
  #include "FunctionDefs.h"

CustomFuns myFuns;


const byte interruptPin = 2;
boolean collectingData=0;
boolean triggerMode = 0;

void setup() {
//GENERAL
        Serial.begin(115200);
        Serial.setTimeout(20);
        pinMode(interruptPin, INPUT_PULLUP);
        attachInterrupt(digitalPinToInterrupt(interruptPin), triggerISR, RISING);

    //LEDs
          myFuns.InitiatlizeLEDs();
          myFuns.LEDBounce();
          myFuns.LEDClear();
          
          myFuns.InitializeSensors();



           //INTERRUPTS
        //Set up pins for Debugging
            //set pins as outputs
            pinMode(togglePin, OUTPUT);

        //Stop Interrupts
            cli();

        //Set up an Interrupt Timer for consistant measurements
           myFuns.TimerMath(desiredFreq);
           myFuns.TimerSetup();


        //Allow interrupts again
            sei();


}


//CHANGE THIS LATER <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

//Set up Interrupt Service Routine
    ISR(TIMER1_COMPA_vect){//timer1 interrupt 1Hz toggles pin 13 (LED)
        
    }





void loop() {
if (firstCall){
        //Serial.println("Starting Program");
        Serial.println("Starting Program");   // print the reading
        Serial.println("SD card initialization failed");

        Serial.println("Setup the Device");   // print the reading

        for(int sensorNum=0; sensorNum < numberOfSensors ; sensorNum++){
            myFuns.SetLightSensorSettings(sensorNum); 
        }
      
        Serial.flush();
        firstCall=0;
        Serial.println("firstCall=0");
        //Serial.println("firstCall=0");
        myFuns.LEDBounce();
        myFuns.LEDClear();
        myFuns.LEDAll();
    }

  


  index=0;
boolean newSerial=0;

if (Serial.available()){

  inDataStr = Serial.readStringUntil('\n');
/*while(Serial.available() > 0){
            
        if(index < 19) // One less than the size of the array
        {
            inChar = Serial.read(); // Read a character
            inData[index] = inChar; // Store it
            index++; // Increment where to write next
            inData[index] = '\0'; // Null terminate the string
        }
        
    }*/
    newSerial=1;
}


if (state){
  if (triggerMode){
    //Triggering mode (ON right now)
    if (collectingData){
      myFuns.AquireData();
      collectingData=0;
    }
  }
  else{
    //Stream of data (OFF right now)
    myFuns.AquireData();
    //delay(980);
    delay(50);
  }
}


if (newSerial){

  inDataStr.toCharArray(inData, 20);


    //Mirror the input
    Serial.println(inDataStr);
    if (inData[0] != '-'){

    
    String inDataStr(inData);
    inDataStr.replace("-", "");
    
    
    // say what you got:
    //Serial.print("I received: ");
    //Serial.println(inDataStr);

    if(inDataStr.startsWith("OFF")){
      Serial.println("Turn OFF Data Collection");
      myFuns.DataColectionOff(0);                 
    }
    else if (inDataStr.startsWith("ON")){
      Serial.println("Turn ON Data Collection");
      myFuns.DataColectionOn(0);
    }
    else if (inDataStr.startsWith("ON1")){
      Serial.println("Turn ON Data Collection");
      myFuns.DataColectionOn(0);
    }
    else if (inDataStr.startsWith("RS01")){
      Serial.println("Reset SD Card");
    }
    else if (inDataStr.startsWith("RS00")){
      Serial.println("Reset Device");
      myFuns.DataColectionOff(0);
      myFuns.ResetArduino();
    }
    else if (inDataStr.startsWith("SAVE")){
      Serial.println("Save Settings to EEPORM");
      myFuns.SaveLightSensorSettings();
    }
    else if (inDataStr.startsWith("READ")){
      Serial.println("READ Settings from EEPORM");
      myFuns.ReadLightSensorSettings();
    }
    else if (inDataStr.startsWith("MOD")){
      //Serial.println("Modify sensor settings");
      myFuns.ModifyLightSensorSettings(inData,inDataStr);
    }
    else if (inDataStr.startsWith("DEF")){
      Serial.println("Revert Sensor Settings to Default");
      //ModifyLightSensorSettings(inData);
    }
    
    else if (inDataStr.startsWith("DISP")){
      Serial.println("Current Settings");
      myFuns.SensorStateDisp();
    }

    else if (inDataStr.startsWith("RDFREQ")){
        Serial.println(desiredFreq);
    }

    else if (inDataStr.startsWith("TRIG")){
      if (inDataStr.substring(4,6)=="ON"){
        triggerMode=1;
      }
      else{
        triggerMode=0;
      }
    }

    else if (inDataStr.startsWith("SDN")){
        int desiredNum = inDataStr.substring(3).toInt();
        myFuns.setFileName(desiredNum);
        Serial.print("New SD File Number: ");
        Serial.println(desiredNum);
    }
    
    
    else if (inDataStr.startsWith("FREQ")){
      
      desiredFreq = inDataStr.substring(4).toFloat();

      /*if (freq>20 || freq<=0){
          Serial.print("Invalid Frequency: ");
          Serial.print(freq);
          Serial.println("    Try Again!");
      }
      else{ */

          if (state==0){
          Serial.print("New Frequency: ");
          Serial.println(desiredFreq);
          }
                 
          //DataColectionOff(1);
          myFuns.DataColectionOff(2);
          myFuns.TimerMath(desiredFreq);
          if(state==1){
              myFuns.DataColectionOn(1);
          }
    //}

    

}
else{

  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< This might not work with software serial
  Serial.println("Unrecognized Command");
  while(Serial.available() > 0)
   Serial.read();
  }
  
    }

    //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< This might not work with software serial
else{
  Serial.println("Unrecognized Command");
  while(Serial.available() > 0)
   Serial.read();
  }


}
}
    
void triggerISR(){
  collectingData=1;
  }


