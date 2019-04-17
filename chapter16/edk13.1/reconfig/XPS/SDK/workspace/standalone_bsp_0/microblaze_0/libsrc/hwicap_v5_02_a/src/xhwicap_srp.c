/* $Id: xhwicap_srp.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
/******************************************************************************
*
* (c) Copyright 2003-2010 Xilinx, Inc. All rights reserved.
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
/****************************************************************************/
/**
*
* @file xhwicap_srp.c
*
* This file contains the functions of the XHwIcap driver used to access the
* configuration memory of the Xilinx FPGAs through the ICAP port.
*
* These APIs provide methods for reading and writing data, frames, and partial
* bitstreams to the ICAP port. See xhwicap.h for a detailed description of the
* driver.
*
* @note
*
* Only Virtex4, Virtex5, Virtex6 and Spartan6 devices are supported.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/17/03 First release
* 1.01a sv   03/03/07 V4 Updates.
* 2.00a ecm  10/20/07 V5 Support
* 4.00a hvm  11/30/09 Added support for V6 and updated with HAL phase 1
*		      modifications
* 5.00a hvm  2/25/10  Added support for S6
* 5.00a hvm  5/21/10  Modified XHwIcap_GetConfigReg function for V4/V5/V6/S6
*			command sequence. Added one extra NOP before the
*			Type 1 read config register command and removed an
*			extra NOP after the config register command.
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include <xil_types.h>
#include <xil_assert.h>
#include "xhwicap.h"

/************************** Constant Definitions *****************************/

#define DESYNC_COMMAND_SIZE	7 /* Number of words in the Desync command */
#define CAPTURE_COMMAND_SIZE	7 /* Number of words in the Capture command */
#if XHI_FAMILY == XHI_DEV_FAMILY_S6
#define READ_CFG_REG_COMMAND_SIZE 7 /* Num of words in Read Config command */
#else
#define READ_CFG_REG_COMMAND_SIZE 6 /* Num of words in Read Config command */
#endif
/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/

/****************************************************************************/
/**
*
* Sends a DESYNC command to the ICAP port.
*
* @param	InstancePtr - a pointer to the XHwIcap instance to be worked on.
*
* @return	XST_SUCCESS else XST_FAILURE
*
* @note		None.
*
*****************************************************************************/
int XHwIcap_CommandDesync(XHwIcap *InstancePtr)
{
	int Status;
#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	u16 FrameBuffer[DESYNC_COMMAND_SIZE];
#else
	u32 FrameBuffer[DESYNC_COMMAND_SIZE];
#endif
	u32 Index =0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Create the data to be written to the ICAP.
	 */
	FrameBuffer[Index++] = (XHwIcap_Type1Write(XHI_CMD) | 1);
	FrameBuffer[Index++] = XHI_CMD_DESYNCH;
	FrameBuffer[Index++] = XHI_DUMMY_PACKET;
	FrameBuffer[Index++] = XHI_DUMMY_PACKET;


	/*
	 * Write the data to the FIFO and intiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, &FrameBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

#if (XHI_FAMILY != XHI_DEV_FAMILY_S6)
/****************************************************************************/
/**
*
* Sends a CAPTURE command to the ICAP port.  This command captures all
* of the flip flop states so they will be available during readback.
* One can use this command instead of enabling the CAPTURE block in the
* design.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	XST_SUCCESS or XST_FAILURE
*
* @note		None.
*
*****************************************************************************/
int XHwIcap_CommandCapture(XHwIcap *InstancePtr)
{
	int Status;
	u32 FrameBuffer[CAPTURE_COMMAND_SIZE];
	u32 Index =0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Create the data to be written to the ICAP.
	 */
	FrameBuffer[Index++] = XHI_DUMMY_PACKET;
	FrameBuffer[Index++] = XHI_SYNC_PACKET;
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
	FrameBuffer[Index++] = XHI_NOOP_PACKET;
#endif
	FrameBuffer[Index++] = (XHwIcap_Type1Write(XHI_CMD) | 1);
	FrameBuffer[Index++] = XHI_CMD_GCAPTURE;
	FrameBuffer[Index++] =  XHI_DUMMY_PACKET;
	FrameBuffer[Index++] =  XHI_DUMMY_PACKET;

	/*
	 * Write the data to the FIFO and intiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, &FrameBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
#endif
/****************************************************************************/
/**
 *
 * This function returns the value of the specified configuration register.
 *
 * @param	InstancePtr is a pointer to the XHwIcap instance.
 * @param	ConfigReg  is a constant which represents the configuration
 *		register value to be returned. Constants specified in
 *		xhwicap_i.h.
 * 		Examples:  XHI_IDCODE, XHI_FLR.
 * @param	RegData is the value of the specified configuration
 *		register.
 *
 * @return	XST_SUCCESS or XST_FAILURE
 *
 * @note	This is a blocking call.
 *
 *****************************************************************************/
u32 XHwIcap_GetConfigReg(XHwIcap *InstancePtr, u32 ConfigReg, u32 *RegData)
{
	int Status;
	u32 Retries =0;
#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	u16 FrameBuffer[READ_CFG_REG_COMMAND_SIZE];
#else
	u32 FrameBuffer[READ_CFG_REG_COMMAND_SIZE];
#endif
	u32 Index =0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Create the data to be written to the ICAP.
	 */
	FrameBuffer[Index++] = XHI_DUMMY_PACKET;

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	FrameBuffer[Index++] = XHI_SYNC_PACKET1;
	FrameBuffer[Index++] = XHI_SYNC_PACKET2;
#else
	FrameBuffer[Index++] = XHI_SYNC_PACKET;
#endif
	FrameBuffer[Index++] = XHI_NOOP_PACKET;
	FrameBuffer[Index++] = XHI_NOOP_PACKET;

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	if (ConfigReg == XHI_IDCODE) {
		FrameBuffer[Index++] = XHwIcap_Type1Read(ConfigReg) | 0x2;
	}else {
		FrameBuffer[Index++] = XHwIcap_Type1Read(ConfigReg) | 0x1;
	}
#else
	FrameBuffer[Index++] = XHwIcap_Type1Read(ConfigReg) | 0x1;
#endif

	FrameBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Write the data to the FIFO and intiate the transfer of data present
	 * in the FIFO to the ICAP device.
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, &FrameBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	while (XHwIcap_IsDeviceBusy(InstancePtr) != FALSE);
	while ((XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) &
					XHI_CR_WRITE_MASK);

	/*
	 * Read the Config Register from the FIFO
	 */
	XHwIcap_SetSizeReg(InstancePtr, 1);

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	if (ConfigReg == XHI_IDCODE) {
		XHwIcap_SetSizeReg(InstancePtr, 2);
	}
#endif
	XHwIcap_StartReadBack(InstancePtr);
	while (XHwIcap_IsDeviceBusy(InstancePtr) != FALSE) {
			Retries++;
		if (Retries > XHI_MAX_RETRIES) {
			return XST_FAILURE;
		}
	}
	while ((XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) &
					XHI_CR_READ_MASK);

	/*
	 * Return the IDCODE value
	 */
	*RegData = XHwIcap_FifoRead(InstancePtr);

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	if (ConfigReg == XHI_IDCODE) {
		*RegData = ((*RegData << 16) | (XHwIcap_FifoRead(InstancePtr)));
	}
#endif
	return XST_SUCCESS;
}

