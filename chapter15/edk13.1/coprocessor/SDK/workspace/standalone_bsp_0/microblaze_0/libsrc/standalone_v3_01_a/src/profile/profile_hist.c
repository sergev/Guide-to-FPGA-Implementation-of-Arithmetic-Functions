//
// Copyright (c) 2002-2010 Xilinx, Inc.  All rights reserved.
// Xilinx, Inc.
//
// XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
// COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
// ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
// STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
// IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
// FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
// XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
// THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
// ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
// FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE.
//
// $Id: profile_hist.c,v 1.1.2.2 2010/12/10 12:02:42 svemula Exp $
//
#include "profile.h"
#include "mblaze_nt_types.h"
#include "_profile_timer_hw.h"

#ifdef PROC_PPC
#include "xpseudo_asm.h"
#define SPR_SRR0 0x01A
#endif

extern int binsize ;
uint32_t pc ;

void profile_intr_handler( void )
{

	int j;

#ifdef PROC_MICROBLAZE
	asm( "swi r14, r0, pc" ) ;
#else
	pc = mfspr(SPR_SRR0);
#endif
	//print("PC: "); putnum(pc); print("\r\n");
	for(j = 0; j < n_gmon_sections; j++ ){
		if((pc >= _gmonparam[j].lowpc) && (pc < _gmonparam[j].highpc)) {
			_gmonparam[j].kcount[(pc-_gmonparam[j].lowpc)/(4 * binsize)]++;
			break;
		}
	}
	// Ack the Timer Interrupt
	timer_ack();
}

