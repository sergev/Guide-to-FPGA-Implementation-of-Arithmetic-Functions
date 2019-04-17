#include <stdio.h>			//declaration of xil_print() function
#include <mb_interface.h>	//declaration of microblaze functions to enable/disable interrupts
#include <xintc_l.h>		//declaration of the interrupt controller funcions (XIntc_XXX)
#include <xuartlite_l.h>	//declaration of the UART functions (XUartLite_XXX)
#include <xparameters.h>	//declaration of XPAR_INSTANCE_BASEADDR's and XPAR_TIMER_CLOCK_FREQ_HZ
#include <plb_led7seg.h>	//Header of the driver

/***************************************************************/
unsigned short data;			//processed data in the main() function, and used by the interrupt service to display in the 7-segments LCD
volatile bool endloop;			//volatile to avoid optimization malfunction

/***************************************************************/
void isr_rs232()
{
bool rs232_emptyRX=XUartLite_IsReceiveEmpty(XPAR_RS232_BASEADDR);	//Checks if the receive buffer is empty
if(!rs232_emptyRX)
	{
	char rs232_char=XUartLite_RecvByte(XPAR_RS232_BASEADDR);		//Reads the received character from buffer, clearing the IRQ if it voids
	switch(rs232_char)
		{
		case '+': Led7Seg_SetData(XPAR_LED7SEG_BASEADDR,++data); break;
		case '-': Led7Seg_SetData(XPAR_LED7SEG_BASEADDR,--data); break;
		case 'z': Led7Seg_SwapZeros(XPAR_LED7SEG_BASEADDR); break; //led7seg_config^=0x1; break;
		case 'o': Led7Seg_SwapOff(XPAR_LED7SEG_BASEADDR); break; //led7seg_config^=0x2; break;
		case 'x': endloop=true; break;
		default: break;
		}
	}
}
/***************************************************************/
int main()
{
endloop=false;				//global variable
data=0;

XUartLite_EnableIntr(XPAR_RS232_BASEADDR);	//enable RS232 interrupts

XIntc_RegisterHandler(XPAR_INT_CONTROL_0_BASEADDR, XPAR_INT_CONTROL_0_RS232_INTERRUPT_INTR, (XInterruptHandler)isr_rs232, NULL);	//register UART's ISR
XIntc_EnableIntr (XPAR_INT_CONTROL_0_BASEADDR, XPAR_RS232_INTERRUPT_MASK);	//enables both IRQ signals in the interrupt controller
XIntc_MasterEnable(XPAR_INT_CONTROL_0_BASEADDR);	//enable global interrupt in the interrupt controller

microblaze_enable_interrupts();

xil_printf("Start\n\r");
while(!endloop)						//Infinite Loop
	{
	//Do anything you want
	}
Led7Seg_SetControl(XPAR_LED7SEG_BASEADDR,LED7SEG_OFF_MASK);			//Display off
xil_printf("End\n\r");

microblaze_disable_interrupts();
return 0;
}
