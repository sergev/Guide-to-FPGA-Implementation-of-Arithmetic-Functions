#include <stdio.h>
#include <xparameters.h>
#include <xhwicap_l.h>
#include "cbitstream.h"

#define HWICAP_ADDR (XPAR_HWICAP_0_BASEADDR)

volatile unsigned int *hwicap_control=(unsigned int*)(HWICAP_ADDR+XHI_CR_OFFSET);
volatile unsigned int *hwicap_status=(unsigned int*)(HWICAP_ADDR+XHI_SR_OFFSET);
volatile unsigned int *hwicap_writefifo=(unsigned int*)(HWICAP_ADDR+XHI_WF_OFFSET);

/***************************************************************/

inline void CBitStream::Hwicap_InitWrite()
{
*hwicap_control=(XHI_CR_SW_ABORT_MASK|XHI_CR_SW_RESET_MASK);	//Abort icap and fifos, and reset hwicap_interrupts
}

/***************************************************************/

inline bool CBitStream::Hwicap_WordWrite(unsigned int word)
{
*hwicap_writefifo=word;
*hwicap_control=XHI_CR_WRITE_MASK;
unsigned int status=*hwicap_status;
if((status&XHI_SR_CFGERR_N_MASK==0)||(status&XHI_SR_IN_ABORT_N_MASK==0))
	return false;
if(status&XHI_SR_DONE_MASK==0)
	while(*hwicap_status&XHI_SR_DONE_MASK==0);
return true;
}

/***************************************************************/

CBitStream::CBitStream()
{
Header=NULL;
Addr=NULL;
Size=0;
Fpga=NULL;
Ncdfile=NULL;
Date=NULL;
Time=NULL;
}

/***************************************************************/

void CBitStream::ReadHeader(unsigned char *header)
{
unsigned int length=0;
Header=header;
Addr=NULL;
Size=0;
Fpga=NULL;
Ncdfile=NULL;
Date=NULL;
Time=NULL;

length=((*header)<<8)|(*(header+1));
header+=(2+length);
length=((*header)<<8)|(*(header+1));
header+=(2+length-1);

for(unsigned char key='a'; key<='e'; key++)
	{
	if(key!=*header++)
		return;
	length=((*header)<<8)|(*(header+1));
	header+=2;
	switch(key)
		{
		case 'a': Ncdfile=header; header+=length; break;
		case 'b': Fpga=header; header+=length; break;
		case 'c': Date=header; header+=length; break;
		case 'd': Time=header; header+=length; break;
		case 'e': Addr=header+2; Size=(length<<16)|((*header)<<8)|(*(header+1)); break;
		}
	}
}

/***************************************************************/

void CBitStream::PrintHeader()
{
xil_printf("bitstream header 0x%x:\r\n",Header);
if(Addr==NULL || Size==0)
	xil_printf("  Invalid\r\n");
else
	{xil_printf("  %s\r\n  %s\r\n  %s %s\r\n",Ncdfile,Fpga,Date,Time);
	xil_printf("  RAW-Data: Addr=0x%x Size=0x%x\r\n",Addr,Size);}
}

/***************************************************************/

bool CBitStream::Reconfig()
{
if(Addr==NULL || Size==0)
	return false;

unsigned char *addr=Addr;
unsigned char *max=Addr+Size;

Hwicap_InitWrite();
while(addr<max)
	{
	unsigned int word=0;
	for(unsigned char k=0; k<4; k++)
		word=(word<<8)|(*addr++);
	if(!Hwicap_WordWrite(word))
		return false;
	}
return true;
}

