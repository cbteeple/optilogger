# optilogger

## Introduction
OptiLogger is aset of arduino code and MATLAB code that coordinates data collection from digital light intensity sensors.

## Hardware
- Light intensity sensors: **Lite-On LTR-329ALS-01**
- Microcontroller: **Arduino Nano**
- i2c mux: **TCA9548A 1-to-8 I2C Multiplexer**

### Connections
- *i2c* pins on the light intensity sensors are connect to the *i2c OUT* pins of the mux.
- The *i2c IN* pins of the mux are connected to the *i2c* pins on the MCU (pins A4 and A5).
- The gate on the MOSFET for each LED driver circuit is connected to pins D5-D12 on the MCU.
- 3.3V power is fed to BOTH the mux AND the light intensity sensors
- 5.0V power is fed to the LEDs only. **Do not connect 5V to the light sensors. They will burn up!**

## Software
### Arduino
#### Introduction
The embedded software is written in the Arduino flavor of C++.
To run it, open the* Light_Intensity_Reader_ALL.ino* file, and upload the code to your Arduino Nano.

#### How it works:
Based on commands from a computer, the built-in sensitivity ranges of the sensors are set and data can be collected. This program recieves serial data from a computer to control it (that's how MATLAB interfaces with it). Each sensor's range can be configured from 1x to 96x, and each LED can be turned on and off. The code can also operate in trigger mode

#### Commands:
- **READ**
	- Read settings from on-chip memory
- **SAVE**
	- Save the current settings to on-chip memory
- **MOD[#1][#2][#3]**
	- Modify the settings for a single sensor
	- [#1] : Sensor Number (0-7)
	- [#2] : Sensor On/Off (0 or 1)
	- [#3] : Sensitivity range setting (enum, 0,1,2,3,6,7 corresponds to 1x, 2x, 4x, 8x, 48x, 96x)
- **MODALL**
	- Turn on all LEDs and sensors with whatever current settings are
- **MODCLR**
	- Clear all LEDs and turn off all sensors
- **ON**
	- Start collecting data
- **OFF**
	- Stop collecting data

### MATLAB GUI
There is a matlab GUI that can send all of these commands, and recieve and store data. It is pretty user-friendly, so documentation is sparse.

## [ChangeLog]
Check out the [change log] for info about new versions

**NEW VERSION SHOULD WORK ON MAC NOW!**

[CHANGELOG]: https://github.com/cbteeple/optilogger/blob/master/CHANGELOG.md
[CHANGE LOG]: https://github.com/cbteeple/optilogger/blob/master/CHANGELOG.md
