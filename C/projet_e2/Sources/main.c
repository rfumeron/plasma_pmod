#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasma.h"
#include "../../shared/plasmaMyPrint.h"

#define MemoryRead(A)		(*(volatile unsigned int*)(A))
#define MemoryWrite(A,V)	*(volatile unsigned int*)(A)=(V)
#define MAX_DATA			40000
#define FIFO_REQUEST		0xFFFFFFFF
#define CTRL_MIC_ADDR       0x40000508
#define RESET_MIC_ADDR  	0x40000504
#define DATA_MIC_ADDR		0x40000500

int main(int argc, char ** argv)
{
	puts("Projet DTM 2018 (All Rights Reserved)\n");

	unsigned int sw;
	unsigned char data;
	int compteur = MAX_DATA;

	//reset de la FIFO
	MemoryWrite(RESET_MIC_ADDR, 1);
	MemoryWrite(RESET_MIC_ADDR, 0);

	// initialisation de la FIFO
	MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST);

	while (compteur)
	{
		MemoryWrite(CTRL_MIC_ADDR, FIFO_REQUEST);	// Demande de donn�es � la FIFO
		sw = MemoryRead(DATA_MIC_ADDR);				// Lecture des donn�es
		if (sw) {									// V�rification que l'on a une donn�e (sw = 0 si pas de donn�es dans la FIFO)
			data = (unsigned char)(sw >> 24);						// data = MSBs (7 bits)
			my_printf("", data);					// Affichage de la donn�es
			compteur--;
		}
	}
	while (1)
	{
	}
	return 0;
}
