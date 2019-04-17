#include <stdio.h>			//declaration of xil_print() function
#include <mb_interface.h>	//declaration of microblaze functions to enable/disable interrupts
#include <xintc_l.h>		//declaration of the interrupt controller funcions (XIntc_XXX)
#include <xuartlite_l.h>	//declaration of the UART functions (XUartLite_XXX)
#include <xtmrctr_l.h>		//declaration of the timer functions (XTmrCtr_XXXX)
#include <xparameters.h>	//declaration of XPAR_INSTANCE_BASEADDR's and XPAR_TIMER_CLOCK_FREQ_HZ
#include "led7seg.h"		//declaration of the class CLed7Seg

#define LED7SEG_REFRESH_PERIOD_US (5000)		//5ms = 5000us
#define LED7SEG_REFRESH_COUNTS (LED7SEG_REFRESH_PERIOD_US*(XPAR_TIMER_CLOCK_FREQ_HZ/1000000))

/***************************************************************/
CLed7Seg Display(XPAR_LED7SEG_BASEADDR);	//Constructor of object Display of class CLed7Seg
unsigned short data;						//processed data in the main() function, and used by the interrupt service to display in the 7-segments LCD
volatile bool endloop;						//volatile to avoid malfunction due to compiler optimizations
/***************************************************************/
void isr_timer()
{
static int sw1=-1;
volatile int *gpio_data_switches=(int*)(XPAR_SWITCHES_BASEADDR+0);
int sw2=*gpio_data_switches;	//Reads switches state
if(sw1==-1) sw1=sw2;
Display.Config^=(sw1^sw2);		//Changes the Configuration of the Display if the switches are changed. It uses two XOR operators
Display.Data=data;				//Updates the displayed data
Display.Refresh();				//Refreshes the display 
sw1=sw2;						//Stores the switches state
XTmrCtr_SetControlStatusReg(XPAR_TIMER_BASEADDR, 0, XTC_CSR_INT_OCCURED_MASK|XTC_CSR_AUTO_RELOAD_MASK|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK|XTC_CSR_ENABLE_TMR_MASK);	//Clears the timer's IRQ
}

void isr_rs232()
{
bool rs232_emptyRX=XUartLite_IsReceiveEmpty(XPAR_RS232_BASEADDR);	//Checks if the receive buffer is empty
if(!rs232_emptyRX)
	{
	char rs232_char=XUartLite_RecvByte(XPAR_RS232_BASEADDR);		//Reads the received character from buffer, clearing the IRQ if it voids
	switch(rs232_char)
		{
		case '+': data++; break;
		case '-': data--; break;
		case 'z': Display.Config^=LED7SEG_ZEROS; break;
		case 'o': Display.Config^=LED7SEG_OFF; break;
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

XTmrCtr_SetLoadReg(XPAR_TIMER_BASEADDR, 0, LED7SEG_REFRESH_COUNTS);			//Writes TLR0 register
XTmrCtr_SetControlStatusReg(XPAR_TIMER_BASEADDR, 0, XTC_CSR_LOAD_MASK );	//Writes TCSR0 to load the counter register with the stored value in TLR0
XTmrCtr_SetControlStatusReg(XPAR_TIMER_BASEADDR, 0, XTC_CSR_AUTO_RELOAD_MASK|XTC_CSR_ENABLE_INT_MASK|XTC_CSR_DOWN_COUNT_MASK|XTC_CSR_ENABLE_TMR_MASK);	//Writes TCSR0 to enable counter (capture mode), decrement, auto-reload, enable interrupt

XUartLite_EnableIntr(XPAR_RS232_BASEADDR);	//enable RS232 interrupts

XIntc_RegisterHandler(XPAR_INT_CONTROL_0_BASEADDR, XPAR_INT_CONTROL_0_TIMER_INTERRUPT_INTR, (XInterruptHandler)isr_timer, NULL);	//register Timer's ISR
XIntc_RegisterHandler(XPAR_INT_CONTROL_0_BASEADDR, XPAR_INT_CONTROL_0_RS232_INTERRUPT_INTR, (XInterruptHandler)isr_rs232, NULL);	//register UART's ISR
XIntc_EnableIntr (XPAR_INT_CONTROL_0_BASEADDR, XPAR_TIMER_INTERRUPT_MASK|XPAR_RS232_INTERRUPT_MASK);	//enables both IRQ signals in the interrupt controller
XIntc_MasterEnable(XPAR_INT_CONTROL_0_BASEADDR);	//enable global interrupt in the interrupt controller

microblaze_enable_interrupts();		//standalone OS function

xil_printf("Start\n");
while(!endloop)						//Infinite Loop
	{
	//Do anything you want
	}
Display.Config=LED7SEG_OFF;			//Display off
Display.Refresh();
xil_printf("End\n");				//printf("End\n");

microblaze_disable_interrupts();
return 0;
}