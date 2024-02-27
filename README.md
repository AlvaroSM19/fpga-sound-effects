Sound Effect Project

Effects are applied on Real Time, so audio from Mobile or PC passes through FPGA and goes to a Speaker.

3 effects :
	- Distorsion
	- Echo
	- Lowpass

Filters are in parallel, so only one filter at a time.

Each effect has 5 levels of intensity (from 0 (no effect) to 4)

The intensity of each effect is described as :
	
Distorsion : as the level increase , the sound will be more distorsed.
Echo : as the level increase , the echo delay will increase.
Lowpass : as the level increase, the cutoff frequency will dicrease (this is an approach as the frequency response of the filter is not a perfect lowpass filter, but a sinc function).

UART : each time you change the filter, it will be shown on the serial terminal which filter you are using.

The 4 switches are used for the filter selection.
	Switch 1 : Distorsion filter.
	Switch 2 : Lowpass filter.
	Switch 3 : Echo effect.
	Switch 4 : UART enable/disable.


 A filter will only work if only one of the 3 effects switches are on.


Demo Video : https://www.youtube.com/watch?v=-Fg75exWBlI
