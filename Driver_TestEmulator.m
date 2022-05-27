clear all % Clear Workspace
close all % Close all figure

% You can use this code to emulate the movement that you would obtain in
% lab with the acutal CNC axis.
% Remember that the control box have different "Addresses" on Windows and
% MacOs, by default it is 'COM3' or higher on Windows and '/dev/ttyXXXXX'
% on MacOs.

% Declare the physical control box:
% s = serial('COM3')

s = CNC_Emulator;       % Declare the emulator
set( s, 'EnableTrace')  % Enable tracing function in the emulator

% Open the connection to the control box or emulator
fopen(s)                

% Short pause to make sure the connection is established
pause(2)

% Setup the coordinates system of the CNC axis
fprintf(s, 'G17 G20 G90 G94 G54')

% Send G-Code to the CNC axis 
fprintf(s, 'G1 x2.0 F20')                   % Move to x = 2.0 inch
fprintf(s, 'G1 y2.0 F20')                   % Move to y = 2.0 inch
fprintf(s, 'G1 x0.0 F20')                   % Move back to x = 0.0
fprintf(s, 'G3 x0.0 y0.0 i-1.0 j-1.0  F20') % Move back to (0.0, 0.0) using a counter clock-wise rotation aroung (-1.0, 1.0)

% Close the connection
fclose(s)

