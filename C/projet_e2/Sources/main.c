

#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasma.h"
#include "../../shared/plasmaMyPrint.h"

#define MemoryRead(A)		(*(volatile unsigned int*)(A))
#define MemoryWrite(A,V)	*(volatile unsigned int*)(A)=(V)
#define FIFO_REQUEST		0xFFFFFFFF
#define CTRL_MIC_ADDR       0x40000508
#define RESET_MIC_ADDR  	0x40000504
#define DATA_MIC_ADDR		0x40000500

unsigned int screen[96];

void printPixel(char row, char col, int color)
{
	int buff = 0x00000000;

	buff = color;
	buff = (buff << 8) | row;
	buff = (buff << 8) | col;

	MemoryWrite(OLED_BITMAP_RW, buff);
}

void wipeScreen(void)
{
	int buff = 0;
	for(int i=0; i<256*256;i++)
	{
		MemoryWrite(OLED_BITMAP_RW, buff);
		buff += 1;
	}
}

int main(int argc, char ** argv)
{
	puts("Projet DTM 2018 (All Rights Reserved)\n");

	volatile unsigned int sw = 0;
	volatile unsigned char data;
	volatile int aff = 0;
	volatile int i;
	volatile int j;

	//reset de la FIFO
	MemoryWrite(RESET_MIC_ADDR, 1);
	MemoryWrite(OLED_MUX, OLED_MUX_BITMAP);
	MemoryWrite(OLED_BITMAP_RST, 1); // Reset the oled_rgb PMOD

	wipeScreen();

	for(i=0;i<95;i++)
	{
		screen[i] = 32;
	}

	i = 0;
	while(1)
	{
		// MemoryWrite(RESET_MIC_ADDR, 1);
		MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST);	// Demande de donn�es � la FIFO
		//MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_1);

		sw = MemoryRead(DATA_MIC_ADDR);
		data = (unsigned char)(sw >> 25);
		if (sw && (i != 0 || data == 32)) {
			if (i==1 && (screen[0] >= data))
			{
				i = 0;
			} else {
				//if (sw < 0)
				//while(1);						// data = MSBs (7 bits)
				//my_printf("", data);
				// printPixel(data, i, 0xFFFF);
				screen[i] = data;
				// if (i != 0)
				// {
				// 	while(data != screen[i-1])
				// 	{
				// 		if (data < screen[i-1])
				// 		{
				// 			data++;
				// 		} else {
				// 			data--;
				// 		}
				// 		printPixel(data, i, 0xFFFF);
				// 	}
				// }
				if (i == 95)
				{
					// for(volatile int j = 0; j<500000; j++);
					for(i = 1; i<95; i++)
					{
						for(j = 0; j<64; j++)
						{
							if (((screen[i] >= j) && (screen[i-1] <= j)) || (screen[i] <= j) && (screen[i-1] >= j))
							{
								 printPixel(j, i, 0x07E0);
							} else {
								 printPixel(j, i, 0x0000);
							}
						}
					}
					i=0;
					//wipeScreen();
				//	my_printf("", i);
					//for(j = 0; j<1000000; j++);
				} else {
					i++;
					//for(volatile int j = 0; j<10000; j++);
					//while(1);
				}				// Affichage de la donn�es
				//compteur--;
			}
		}
	}

	// initialisation de la FIFO
	// sw = MemoryRead(DATA_MIC_ADDR);
	// my_printf("Data : ", sw);
	// MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_2);
	// sw = MemoryRead(DATA_MIC_ADDR);
	// my_printf("Data : ", sw);
	// MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_1);
	// sw = MemoryRead(DATA_MIC_ADDR);
	// my_printf("Data : ", sw);
	// for(volatile int i = 0; i<1000000; i++);
	// MemoryWrite(CTRL_MIC_ADDR, 0xFFFFFFFF);
	// sw = MemoryRead(DATA_MIC_ADDR);
	// my_printf("Data : ", sw);
	// while(1);
	while (1)
	{
		MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST);	// Demande de donn�es � la FIFO
		//MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_1);

		sw = MemoryRead(DATA_MIC_ADDR);
		// if (sw)
		// 	my_printf("Data : ", sw);				// Lecture des donn�es
		if (sw) {									// V�rification que l'on a une donn�e (sw = 0 si pas de donn�es dans la FIFO)
			data = (unsigned char)(sw >> 24);
			//if(data != 64)						// data = MSBs (7 bits)
			my_printf("", data);					// Affichage de la donn�es
			//compteur--;
		}
	}
	while (1)
	{
	}
	return 0;
}
