#include "led7seg.h"

/***************************************************************/
void CLed7Seg::GPIO(unsigned char anodes,unsigned char segments)
{
if(LED7SEG_SEGMENTS_ACTIVE_LOW) segments=(~segments)&0x7F;
if(LED7SEG_ANODES_ACTIVE_LOW) anodes=(~anodes)&0x0F;
*GPIO_Data=(anodes<<7)|segments;
}

char CLed7Seg::Decode(char d)
{
switch(d)
	{
	case 0: return 0x3F;
	case 1: return 0x06;
	case 2: return 0x5B;
	case 3: return 0x4F;
	case 4: return 0x66;
	case 5: return 0x6D;
	case 6: return 0x7D;
	case 7: return 0x07;
	case 8: return 0x7F;
	case 9: return 0x67;
	case 10: return 0x77;
	case 11: return 0x7C;
	case 12: return 0x39;
	case 13: return 0x5E;
	case 14: return 0x79;
	case 15: return 0x71;
	default: return 0x00;
	}
}

void CLed7Seg::Digit(char off,char zeros,short data,char idx)
{
static char prev_zero;
char anodes;
char segments;

if(off==1)
	{
	anodes=0;
	segments=0;
	}
else
	{
	char digit4=(data>>(idx*4))&0x0F;
	segments=Decode(digit4);
	anodes=1<<idx;
	if(idx==3)
		prev_zero=1;
	if(digit4==0)
		{
		if(zeros==0 && prev_zero==1 && idx!=0)
			anodes=0;
		}
	else
		prev_zero=0;
	}
GPIO(anodes,segments);
}

void CLed7Seg::Refresh()
{
static char idx=3;
char off=(Config&0x02)>>1;
char zeros=(Config&0x01);
Digit(off,zeros,Data,idx);
idx=(idx==0)? 3 : idx-1;
}

CLed7Seg::CLed7Seg(int gpio_baseaddr)
{
GPIO_Data=(int*)(gpio_baseaddr);
}

