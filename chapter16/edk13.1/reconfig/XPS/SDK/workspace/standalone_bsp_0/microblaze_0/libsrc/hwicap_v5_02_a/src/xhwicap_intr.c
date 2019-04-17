/* $Id: xhwicap_intr.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
/******************************************************************************
*
* (c) Copyright 2007-2010 Xilinx, Inc. All rights reserved.
*
* This file contains confidential and proprietary information of Xilinx, Inc.
* and is protected under U.S. and international copyright and other
* intellectual property laws.
*
* DISCLAIMER
* This disclaimer is not a license and does not grant any rights to the
* materials distributed herewith. Except as otherwise provided in a valid
* license issued to you by Xilinx, and to the maximum extent permitted by
* applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
* FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
* IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
* MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
* and (2) Xilinx shall not be liable (whether in contract or tort, including
* negligence, or under any other theory of liability) for any loss or damage
* of any kind or nature related to, arising under or in connection with these
* materials, including for any direct, or any indirect, special, incidental,
* or consequential loss or damage (including loss of data, profits, goodwill,
* or any type of loss or damage suffered as a result of any action brought by
* a third party) even if such damage or loss was reasonably foreseeable or
* Xilinx had been advised of the possibility of the same.
*
* CRITICAL APPLICATIONS
* Xilinx products are not designed or intended to be fail-safe, or for use in
* any application requiring fail-safe performance, such as life-support or
* safety devices or systems, Class III medical devices, nuclear facilities,
* applications related to the deployment of airbags, or any other applications
* that could lead to death, personal injury, or severe property or
* environmental damage (individually and collectively, "Critical
* Applications"). Customer assumes the sole risk and liability of any use of
* Xilinx products in Critical Applications, subject only to applicable laws
* and regulations governing limitations on product liability.
*
* THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
* AT ALL TIMES.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xhwicap_intr.c
*
* This file contains interrupt handling API functions of the HwIcap device.
*
* Refer to xhwicap.h header file and device specification for more information.
*
* @note
*
* Calling the interrupt functions without including the interrupt component will
* result in asserts if asserts are enabled, and will result in a unpredictable
* behavior if the asserts are not enabled.
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who    Date     Changes
* ----- -----  -------- -----------------------------------------------------
* 2.00a  sv    09/22/07 First release
* 4.00a  hvm   12/1/09  Updated with HAL phase 1 changes
*
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xhwicap.h"

/************************** Constant Definitions *****************************/

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/


/*****************************************************************************/
/**
*
* Sets the status callback function, the status handler, which the driver calls
* when it encounters conditions that should be reported to the higher layer
* software. The handler executes in an interrupt context, so it must minimize
* the amount of processing performed such as transferring data to a thread
* context. One of the following status events is passed to the status handler.
* <pre>
*
* </pre>
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	CallBackRef is the upper layer callback reference passed back
*		when the callback function is invoked.
* @param	FuncPtr is the pointer to the callback function.
*
* @return	None.
*
* @note
*
* The handler is called within interrupt context, so it should do its work
* quickly and queue potentially time-consuming work to a task-level thread.
*
******************************************************************************/
void XHwIcap_SetInterruptHandler(XHwIcap * InstancePtr, void *CallBackRef,
			   		XHwIcap_StatusHandler FuncPtr)
{
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(FuncPtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	InstancePtr->StatusHandler = FuncPtr;
	InstancePtr->StatusRef = CallBackRef;
}

/*****************************************************************************/
/**
*
* The interrupt handler for HwIcap interrupts. This function must be connected
* by the user to an interrupt source.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		The interrupts are being used only while writing data to the
*		ICAP device. The reading of the data from the ICAP device is
*		done in polled mode.
*		In a worst case scenario the interrupt handler can
*		be busy writing large amount of data to the Write FIFO.
*
******************************************************************************/
void XHwIcap_IntrHandler(void *InstancePtr)
{
	XHwIcap *HwIcapPtr = (XHwIcap *) InstancePtr;
	u32 IntrStatus;
	u32 WrFifoVacancy;


	Xil_AssertVoid(InstancePtr != NULL);


	/*
	 * Get the Interrupt status.
	 */
	IntrStatus = XHwIcap_IntrGetStatus(HwIcapPtr);

	if (IntrStatus & XHI_IPIXR_WRP_MASK) {

		/*
		 * A transmit has just completed. Check for more data
		 * to transmit.
		 */
		if (HwIcapPtr->RemainingWords > 0) {

			/*
			 * Fill the FIFO with as many words as it will take (or
			 * as many as we have to write). We can use the Write
			 * FIFO vacancy to know if the device can take more data.
			 */
			WrFifoVacancy = XHwIcap_GetWrFifoVacancy(HwIcapPtr);
			while ((WrFifoVacancy != 0) &&
			       (HwIcapPtr->RemainingWords > 0)) {
				XHwIcap_FifoWrite(HwIcapPtr,
						*HwIcapPtr->SendBufferPtr);

				HwIcapPtr->RemainingWords--;
				WrFifoVacancy--;
				HwIcapPtr->SendBufferPtr++;
			}

			XHwIcap_StartConfig(HwIcapPtr);
		}
		else {

			if (HwIcapPtr->RequestedWords != 0) {

				/*
				 * No more data to send. Disable the interrupts
				 * by disabling the Global Interrupts.
				 * Inform the upper layer software that the
				 * transfer is done.
				 */
				XHwIcap_IntrGlobalDisable(HwIcapPtr);
				HwIcapPtr->IsTransferInProgress = FALSE;
				HwIcapPtr->StatusHandler(HwIcapPtr->StatusRef,
						    XST_HWICAP_WRITE_DONE,
						    HwIcapPtr->RequestedWords);
			}
		}
	}


	/*
	 * Clear the Interrupt status.
	 */
	XHwIcap_IntrClear(HwIcapPtr, IntrStatus);

}

