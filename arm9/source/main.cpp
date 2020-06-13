/*-----------------------------------------------------------------
 Copyright (C) 2005 - 2013
	Michael "Chishm" Chisholm
	Dave "WinterMute" Murphy
	Claudio "sverx"

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

------------------------------------------------------------------*/
#include <nds.h>

#include <fstream>
#include <stdio.h>
#include <fat.h>

void stop(void)
{
	while(1)
    {
		swiWaitForVBlank();
	}
}

void doPause()
{
}

int main(int argc, char **argv)
{
	if (!fatInitDefault())
    {
		consoleDemoInit();
		printf("fatInitDefault failed!");
		stop();
	}

    char currentFolder;
    char currentFolderBankPath[32];

    std::ifstream folderIdentificationFile("sd:/Nintendo 3DS/folder_identification.txt");
    folderIdentificationFile.get(currentFolder);
    folderIdentificationFile.close();
    snprintf(currentFolderBankPath, sizeof(currentFolderBankPath), "sd:/folders_bank/%c", currentFolder);

    char selectedFolderBankPath[32];

    snprintf(selectedFolderBankPath, sizeof(selectedFolderBankPath), "sd:/folders_bank/%c", SELECTED_FOLDER);

    rename("sd:/Nintendo 3DS", currentFolderBankPath);
    rename(selectedFolderBankPath, "sd:/Nintendo 3DS");

	fifoSendValue32(FIFO_USER_01, 1);

	return 0;
}
