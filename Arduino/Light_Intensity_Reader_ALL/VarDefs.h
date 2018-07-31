#ifndef VarDefs_h
#define VarDefs_h

#include "Arduino.h"

//STATE MACHINE
    extern  int state;


//EEPROM
    #define lightSensorActive_Start 0
    #define lightSensorSettings_Start 20
    #define fileNumber_Start 200



//Serial
    extern int pinReset; 
      
    extern char inData[20]; // Allocate some space for the string
    extern String inDataStr;
    extern char inChar; // Where to store the character read
    extern byte index; // Index into array; where to store the character

    //SoftwareSerial SoftSerial(8, 9); // RX, TX




//LED's
    extern int ledPins[]; // LED pins
    extern int ledCnt;
    extern int ledOn[];

//LIGHT SENSORS

    //Set Up Variables and Parameters
        extern const int numberOfSensors;
        extern int reading0;
        extern int reading1;
        extern int reading2;
        extern int reading3;
        extern int reading01[8];
        extern int reading23[8];
            
        extern int Slave_Addr;
        extern int Mux_Addr;
        extern boolean newReading;
    
            
        extern unsigned int lightSensorActive[8];
        extern byte lightSensorSettings[8];

        extern int pressurePin;
        extern float pressure;


//SD CARD READER
    //Set up variables

        extern int fileNumber;
        extern String fileName;
        
        extern int pinCS; // Pin 10 on Arduino Uno
        
        extern int SD_On;
        extern int firstCall;
        extern int delayTime;


//INTERRUPTS
    //Storage variables
        extern boolean toggle0;
        extern int togglePin;
        extern long t_out;
    
    //Set up parameters
        extern long clockFreq;
        extern long counterRes;
        extern float desiredFreq;
    
    
    //Set up Variables
        extern unsigned int clockInputSelect;
        extern unsigned int prescaleExp;
        extern unsigned int outputCompare;
        extern float prescaleBin;


#endif
