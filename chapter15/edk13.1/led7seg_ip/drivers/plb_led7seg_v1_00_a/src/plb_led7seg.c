/*****************************************************************************
* Filename:          plb_led7seg.c
* Version:           1.00.a
* Description:       plb_led7seg Driver Source File
* Date:               (by Create and Import Peripheral Wizard)
*****************************************************************************/


/***************************** Include Files *******************************/

#include "plb_led7seg.h"

/************************** Function Definitions ***************************/

void Led7Seg_SwapControl(int baseaddr, char mask) 
{
Led7Seg_SetControl(baseaddr,Led7Seg_GetStatus(baseaddr)^(mask));
}

void Led7Seg_SwapOff(int baseaddr)
{
Led7Seg_SwapControl(baseaddr, LED7SEG_OFF_MASK);
}

void Led7Seg_SwapZeros(int baseaddr)
{
Led7Seg_SwapControl(baseaddr, LED7SEG_ZEROS_MASK);
}

