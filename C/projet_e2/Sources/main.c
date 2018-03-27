#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasma.h"
#include "../../shared/plasmaMyPrint.h"

#define MemoryRead(A)		(*(volatile unsigned int*)(A))
#define MemoryWrite(A,V)	*(volatile unsigned int*)(A)=(V)
#define MAX_DATA			40000
#define FIFO_REQUEST_1		0x0000FFFF
#define FIFO_REQUEST_2		0xFFFFFFFF
#define CTRL_MIC_ADDR       0x40000508
#define RESET_MIC_ADDR  	0x40000504
#define DATA_MIC_ADDR		0x40000500

int main(int argc, char ** argv)
{
	puts("Projet DTM 2018 (All Rights Reserved)\n");

	unsigned int sw;
	char data;
	int compteur = MAX_DATA;

	//reset de la FIFO
	MemoryWrite(RESET_MIC_ADDR, 1);
	MemoryWrite(RESET_MIC_ADDR, 0);

	// initialisation de la FIFO
	sw = MemoryRead(DATA_MIC_ADDR);
	my_printf("Data : ", sw);
	MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_2);
	sw = MemoryRead(DATA_MIC_ADDR);
	my_printf("Data : ", sw);
	MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_1);
	sw = MemoryRead(DATA_MIC_ADDR);
	my_printf("Data : ", sw);
	for(volatile int i = 0; i<1000000; i++);
	MemoryWrite(CTRL_MIC_ADDR, 0xFFFFFFFF);
	sw = MemoryRead(DATA_MIC_ADDR);
	my_printf("Data : ", sw);
	while(1);
	while (compteur)
	{
		MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_2);	// Demande de donn�es � la FIFO
		MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST_1);

		sw = MemoryRead(DATA_MIC_ADDR);
		if (sw)
			my_printf("Data : ", sw);				// Lecture des donn�es
		if (sw) {									// V�rification que l'on a une donn�e (sw = 0 si pas de donn�es dans la FIFO)
			data = (char)(sw >> 24);						// data = MSBs (7 bits)
			my_printf("", data);					// Affichage de la donn�es
			compteur--;
		}
	}
	while (1)
	{
	}
	return 0;
}
