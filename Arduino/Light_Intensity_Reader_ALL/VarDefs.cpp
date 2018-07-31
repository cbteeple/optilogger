#include "Arduino.h"
#include "VarDefs.h"

//STATE MACHINE
    int state = 0;


//EEPROM
    #define lightSensorActive_Start 0
    #define lightSensorSettings_Start 20
    #define fileNumber_Start 200



//Serial
     int pinReset = 7; 
      
     char inData[20]; // Allocate some space for the string
     String inDataStr;
     char inChar; // Where to store the character read
     byte index = 0; // Index into array; where to store the character

    //SoftwareSerial SoftSerial(8, 9); // RX, TX




//LED's
     int ledPins[] = {5, 6, 7, 8, 9, 10, 11, 12}; // LED pins
     int ledCnt = 8;
     int ledOn[8];

//LIGHT SENSORS

    //Set Up Variables and Parameters
         const int numberOfSensors=8;
         int reading0 = 0;
         int reading1 = 0;
         int reading2 = 0;
         int reading3 = 0;
         int reading01[numberOfSensors];
         int reading23[numberOfSensors];
            
         int Slave_Addr = 0x29;
         int Mux_Addr   = 0x70;
         boolean newReading=0;
    
            
         unsigned int lightSensorActive[numberOfSensors];
         byte lightSensorSettings[numberOfSensors];



//ANALOG PRESSURE GAUGE
    int pressurePin = 7;
    float pressure=0;
 

//SD CARD READER
    //Set up variables

         int fileNumber = 0;
         String fileName = "0.txt";
        
         int pinCS = 10; // Pin 10 on Arduino Uno
        
         int SD_On = 1;
         int firstCall=1;
         int delayTime=0;


//INTERRUPTS
    //Storage variables
         boolean toggle0 = 0;
         int togglePin = 4;
         long t_out = 0;
    
    //Set up parameters
         long clockFreq = 8000000L;
         long counterRes = pow(2,16);
         float desiredFreq = 10;
    
    
    //Set up Variables
         unsigned int clockInputSelect = 1;
         unsigned int prescaleExp = 1;
         unsigned int outputCompare=0;
         float prescaleBin = 0.0;
