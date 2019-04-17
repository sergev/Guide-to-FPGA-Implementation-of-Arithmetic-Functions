/*
 * Empty C++ Application
 */

#include <xparameters.h>	//declaration of XPAR_INSTANCE_BASEADDR's
#include <plb_led7seg.h>	//header of the peripheral's driver

#define DELAY_COUNTS (100)

//Compile no-optimization to avoid the gcc eliminating the delay
void delay()
{
for(int j=0; j<DELAY_COUNTS; j++);
}

int main()
{
Led7Seg_SetData(XPAR_LED7SEG_BASEADDR,0x001E);
Led7Seg_SetControl(XPAR_LED7SEG_BASEADDR,0x0);
delay();
Led7Seg_SetControl(XPAR_LED7SEG_BASEADDR,LED7SEG_ZEROS_MASK);
delay();
Led7Seg_SetControl(XPAR_LED7SEG_BASEADDR,LED7SEG_OFF_MASK);
delay();
Led7Seg_SetControl(XPAR_LED7SEG_BASEADDR,0x0);
delay();
int data=Led7Seg_GetData(XPAR_LED7SEG_BASEADDR)+0xFF;
Led7Seg_SetData(XPAR_LED7SEG_BASEADDR,data);
delay();
Led7Seg_SwapOff(XPAR_LED7SEG_BASEADDR);
delay();
Led7Seg_SwapOff(XPAR_LED7SEG_BASEADDR);
delay();
Led7Seg_SwapZeros(XPAR_LED7SEG_BASEADDR);
delay();
Led7Seg_SwapZeros(XPAR_LED7SEG_BASEADDR);
delay();

}
