# ChangeLog

## [1.1] - 2018-08-17
### Added
- none

### Changed
- Arduino Firmware
  - Updated handling of commands
    - Serial read is handled better in it's own function
    - Incomming commands are handled in a more straightforward way
  - Better sample rate handling (when not in trigger mode)
    - Now it's time-based instead of interrupt based
    - Serial commands are handled deterministically now
  - Added command to turn on and off the pressure reading
    - It's off by default, matching the GUI
- MATLAB GUI
  - Better command sending
    - actually using newlines now
  - Added Pressure on/off command to button press
  - Fixed file path issues
    - No longer relying on strings for / or \ in directiry names
    - Should be cross-platform now!

### Removed
- none

## [1.0] - 2018-07-31
### Initial Release

[1.1]: https://github.com/cbteeple/optilogger/compare/v1.0...v1.1
