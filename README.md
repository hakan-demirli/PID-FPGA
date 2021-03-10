# PID-FPGA
PID controller on an FPGA with custom RS232 addressing protocol.

![alt text](https://github.com/hakan-demirli/PID-FPGA/blob/main/BirdsEyeView.png?raw=true)

To capture the motor's precise behavior, data sampling speed is synchronized with the TX module. But unfortunately, most of the serial port terminal programs, including [Terminal v1.9b by Br@y++](https://www.narom.no/undervisningsressurser/the-cansat-book/the-primary-mission/using-the-radio/terminal-program/) and [Termite](https://www.compuphase.com/software_termite.htm), failed to keep up with this speed. [HTerm](http://der-hammer.info/pages/terminal.html) was the only one I found that operated with no problems.

# Communication Protocol
RS232:
 * Data Bits: 8
 * Stop Bits: 1
 * Parity: None
 * Baud Rate 115200  
 
The instructions are 64-bit. The first and the last 8 bits are must be AA and BB, respectively, to ensure package integrity.  
|AA|8bit address|4 bit useless|36Bit data|BB|
The Numbers are fixed point 36 bit signed |1bit|26bit|9bit|  
 * Accessing to address zero sets the global reset to one.
 * Address one is KP
 * Address two is KD
 * Address three is KI
 * Accessing to address zero sets the global reset to zero.  
Examples:  
AA00xxxxxxxxxxBB // reset = 1  
AA010000000500BB // KP = 2.5  
AA020000000500BB // KD = 2.5  
AA030000000500BB // KI = 2.5  
AA0D000000FFFFBB // reset = 0  

# Hardware
 * Altera DE2 FPGA: EP2C35F672C6
 * DC Motor: (unknown)
 * Encoder: ARC S 050
 * Motor Driver: Custom  
 ![alt text](https://github.com/hakan-demirli/PID-FPGA/blob/main/HARDWARE.jpg?raw=true)
# Verification of The Design
 * Quartus project is verified by testbenches.
 * Overall project verified by oscilloscope measurements of the frequency of the encoder signals.
 The motor speed is 14.15708 RPS (7078.54/500). Which is quite close to the desired speed: 14 RPS.  
 ![alt text](https://github.com/hakan-demirli/PID-FPGA/blob/main/14RPS.png?raw=true)  
 * Motor's response to disturbances under PID control:  
  ![alt text](https://github.com/hakan-demirli/PID-FPGA/blob/main/Disturbance.jpg?raw=true)  
  Sudden up and down jumps that created the white halo effect are not a measurement errors. They are created by a misaligned encoder and motor shaft. If you zoom in on the plot on MATLAB, you can see that it is, in fact, a sinusoidal signal.
# Possible Design Improvements and Current Flaws
 * Rotatory Encoder creates 500 pulses for every rotation. But, the calculations are done by dividing the pulse count by 512 in order to avoid a separate division circuit.
 * There is a bug with the multiplication circuit. The numbers are ~0.8% off.
 * In my hardware setup, the DC motor and the Encoder are connected via a custom imperfect shaft that causes a sinusoidal noise on the speed values.
 * After the final debugging, I forgot to change the source of the desired speed from switches to RS232. So, you have to enter the desired speed from switches.
 * Current KP, KD, and KI values are quite low. It takes a couple of seconds for the motor to reach its final value. 
 * There is no integral windup protection.
 * I am a sophomore student with no Control background so that is the best I can do in a week.
 
