/* $Id: xhwicap_selftest.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap_selftest.c
*
* This file contains a diagnostic self test function for the XHwIcap driver.
* The self test functions writes to the Interrupt Enable Register and reads it
* back for comparison.
*
* See xhwicap.h for more information.
*
* @note	None.
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who    Date     Changes
* ----- -----  -------- -----------------------------------------------------
* 1.00a sv     09/17/07 First release
* 4.00a hvm    12/1/09  Updated with HAL phase 1 modifications
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xhwicap.h"

/************************** Constant Definitions ****************************/

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

/************************** Variable Definitions ****************************/

/************************** Function Prototypes *****************************/

/*****************************************************************************/
/**
*
* Run a self-test on the driver/device. The test
*	- Writes to the Interrupt Enable Register and reads it back
*	for comparison.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return
*		- XST_SUCCESS if the value read from the register
*		is the same as the value written.
*		- XST_FAILURE otherwise
*
* @note		None.
*
******************************************************************************/
int XHwIcap_SelfTest(XHwIcap *InstancePtr)
{
	int Status = XST_SUCCESS;
	u32 IeRegister;
	u32 DgieRegister;


	/*
	 * Assert the argument
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);


	/*
	 * Save a copy of the Global Interrupt Enable Register and Interrupt
	 * Enable Register before writing them so that they can be restored.
	 */
	DgieRegister = XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
						XHI_GIER_OFFSET);
	IeRegister = XHwIcap_IntrGetEnabled(InstancePtr);

	/*
	 * Disable the Global Interrupt
	 */
	XHwIcap_IntrGlobalDisable(InstancePtr);


	/*
	 * Disable/Enable the interrupts and then verify that the register
	 * is read back correct.
	 */
	XHwIcap_IntrDisable(InstancePtr, XHI_IPIXR_ALL_MASK);
	if (XHwIcap_IntrGetEnabled(InstancePtr) != 0x0) {
		Status = XST_FAILURE;
	}

	XHwIcap_IntrEnable(InstancePtr, (XHI_IPIXR_WEMPTY_MASK |
					XHI_IPIXR_RDP_MASK));
	if (XHwIcap_IntrGetEnabled(InstancePtr) !=
			(XHI_IPIXR_WEMPTY_MASK | XHI_IPIXR_RDP_MASK)) {
		Status |= XST_FAILURE;
	}

	/*
	 * Restore the Interrupt Enable Register to the value before the
	 * test.
	 */
	XHwIcap_IntrDisable(InstancePtr, XHI_IPIXR_ALL_MASK);
	if (IeRegister != 0) {
		XHwIcap_IntrEnable(InstancePtr, IeRegister);
	}


	/*
	 * Restore the Global Interrupt Enable Register to the value
	 * before the test.
	 */
	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress,
				XHI_GIER_OFFSET, DgieRegister);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
