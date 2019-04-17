/*****************************************************************************
* Filename:          plb_led7seg.h
* Version:           1.00.a
* Description:       plb_led7seg Driver Header File
* Date:              (by Create and Import Peripheral Wizard)
*****************************************************************************/

#ifndef PLB_LED7SEG_H
#define PLB_LED7SEG_H

	#ifdef __cplusplus
	extern "C" {
	#endif
		
		#define LED7SEG_ZEROS_MASK (0x1)
		#define LED7SEG_OFF_MASK (0x2)

		#define Led7Seg_GetData(baseaddr) *((volatile int*)(baseaddr))
		#define Led7Seg_SetData(baseaddr, data) *((volatile int*)(baseaddr))=(int)(data)

		#define Led7Seg_GetStatus(baseaddr) *((volatile int*)(baseaddr+4))
		#define Led7Seg_SetControl(baseaddr, config) *((volatile int*)(baseaddr+4))=(int)(config)

		void Led7Seg_SwapOff(int baseaddr);
		void Led7Seg_SwapZeros(int baseaddr);

	#ifdef __cplusplus
	}
	#endif

#endif 
