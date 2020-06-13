/*---------------------------------------------------------------------------------

	default ARM7 core

		Copyright (C) 2005 - 2010
		Michael Noland (joat)
		Jason Rogers (dovoto)
		Dave Murphy (WinterMute)

	This software is provided 'as-is', without any express or implied
	warranty.  In no event will the authors be held liable for any
	damages arising from the use of this software.

	Permission is granted to anyone to use this software for any
	purpose, including commercial applications, and to alter it and
	redistribute it freely, subject to the following restrictions:

	1.	The origin of this software must not be misrepresented; you
		must not claim that you wrote the original software. If you use
		this software in a product, an acknowledgment in the product
		documentation would be appreciated but is not required.

	2.	Altered source versions must be plainly marked as such, and
		must not be misrepresented as being the original software.

	3.	This notice may not be removed or altered from any source
		distribution.

---------------------------------------------------------------------------------*/
#include <nds.h>

unsigned int * SCFG_EXT=(unsigned int*)0x4004008;

void VcountHandler()
{
	inputGetAndSend();
}

volatile bool exitflag = false;

void powerButtonCB()
{
	exitflag = true;
}

int main() {
    REG_SCFG_ROM = 0x101;
    REG_SCFG_CLK = (BIT(0) | BIT(1) | BIT(2) | BIT(7) | BIT(8));
    REG_SCFG_EXT = 0x93FFFB06;
    *(vu16*)(0x04004012) = 0x1988;
    *(vu16*)(0x04004014) = 0x264C;
    *(vu16*)(0x04004C02) = 0x4000;
	
	readUserSettings();
	ledBlink(0);

	irqInit();
	initClockIRQ();
	fifoInit();
	
	SetYtrigger(80);
	
	installSystemFIFO();

    irqSet(IRQ_VCOUNT, VcountHandler);
	irqEnable(IRQ_VBLANK|IRQ_VCOUNT);

	i2cWriteRegister(0x4A, 0x70, 0x01);		// Bootflag = Warmboot/SkipHealthSafety
	i2cWriteRegister(0x4A, 0x11, 0x01);		// Reset to DSi Menu

    setPowerButtonCB(powerButtonCB);

	while(!exitflag)
    {
		swiWaitForVBlank();
	}

	return 0;
}
