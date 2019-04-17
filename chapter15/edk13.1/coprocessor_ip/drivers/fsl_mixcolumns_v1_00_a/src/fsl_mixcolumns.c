#include <xparameters.h>
#include <fsl.h>
#include "fsl_mixcolumns.h"


//FSL_INPUT_SLOT is the FSL slot from which coprocessor read the input data
//FSL_OUTPUT_SLOT is the FSL slot into which the coprocessor write output data

//Important note!!!
//Since putfsl and getfsl (and related calls) are macros that are
//substituted by assembler functions related to fslX (X is a constant number between 0 to 15), 
//the X (the FSL slot) must be know during the compilation 
//If the instance name of the coprocessor changes
//you must be changed the declarations of FSL_INPUT/OUTPUT_SLOT
//to XPAR_FSL_INSTANCENAME_INPUT/OUTPUT_SLOT_ID (defined in xparameters.h)
//and generate again the BSP  
//The default INSTANCENAME in MHS file will be FSL_MIXCOLUMNS_0

#define FSL_INPUT_SLOT		XPAR_FSL_FSL_MIXCOLUMNS_0_INPUT_SLOT_ID
#define FSL_OUTPUT_SLOT		XPAR_FSL_FSL_MIXCOLUMNS_0_OUTPUT_SLOT_ID


void fsl_mixcolumns(unsigned char mode,unsigned char state[4][4])
{
unsigned int *p1=(unsigned int*)state[0];		
unsigned int *p2=(unsigned int*)state[0];		
cputfsl(mode,FSL_INPUT_SLOT);	//writes mode register
putfsl(*p1++,FSL_INPUT_SLOT);	//writes row#0 to the state register
putfsl(*p1++,FSL_INPUT_SLOT);	//       row#1 
putfsl(*p1++,FSL_INPUT_SLOT);	//       row#2
putfsl(*p1,FSL_INPUT_SLOT);		//       row#3
getfsl(*p2++,FSL_OUTPUT_SLOT);	//reads row#0 from the state register
getfsl(*p2++,FSL_OUTPUT_SLOT);	//      row#1 
getfsl(*p2++,FSL_OUTPUT_SLOT);	//      row#2 
getfsl(*p2,FSL_OUTPUT_SLOT);	//      row#3 
}

