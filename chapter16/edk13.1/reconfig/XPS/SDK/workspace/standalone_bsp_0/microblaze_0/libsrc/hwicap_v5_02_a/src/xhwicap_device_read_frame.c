/* $Id: xhwicap_device_read_frame.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap_device_read_frame.c
*
* This file contains the function that reads a specified frame from the
* device (ICAP) and stores it in the memory specified by the user.
*
* @note none.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/20/03 First release
* 1.01a nps  04/10/06 V4 Support
* 2.00a ecm  10/20/07 V5 Support
* 4.00a hvm  11/30/09 Added support for V6 and updated with HAL phase 1
*					  modifications
* 5.00a hvm  2/25/10  Added support for S6
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xhwicap_i.h"
#include "xhwicap.h"
#include <xil_types.h>
#include <xil_assert.h>

/************************** Constant Definitions ****************************/

#define READ_FRAME_SIZE 20

/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/


/************************** Variable Definitions ****************************/


/************************** Function Prototypes *****************************/
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5 ) ||\
	(XHI_FAMILY == XHI_DEV_FAMILY_V6))
/****************************************************************************/
/**
*
* Reads one frame from the device and puts it in memory specified by the user.
*
* @param	InstancePtr - a pointer to the XHwIcap instance to be worked on.
* @param	Top - top (0) or bottom (1) half of device
* @param	Block - Block Address (XHI_FAR_CLB_BLOCK,
*		XHI_FAR_BRAM_BLOCK, XHI_FAR_BRAM_INT_BLOCK)
* @param	HClkRow - selects the HClk Row
* @param	MajorFrame - selects the column
* @param	MinorFrame - selects frame inside column
* @param	FrameBuffer is a pointer to the memory where the frame read
*		from the device is stored
*
* @return	XST_SUCCESS else XST_FAILURE.
*
* @note		This is a blocking call.
*
*****************************************************************************/
int XHwIcap_DeviceReadFrame(XHwIcap *InstancePtr, long Top, long Block,
				long HClkRow, long MajorFrame, long MinorFrame,
				u32 *FrameBuffer)
{

	u32 Packet;
	u32 Data;
	u32 TotalWords;
	int Status;
	u32 WriteBuffer[READ_FRAME_SIZE];
	u32 Index = 0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameBuffer != NULL);

	/*
	 * DUMMY and SYNC
	 */
	WriteBuffer[Index++] = XHI_DUMMY_PACKET;
	WriteBuffer[Index++] = XHI_SYNC_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Reset CRC
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_CMD_RCRC;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Setup CMD register to read configuration
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_CMD_RCFG;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Setup FAR register.
	 */
	Packet = XHwIcap_Type1Write(XHI_FAR) | 1;
#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* Virtex4 */
	Data = XHwIcap_SetupFarV4(Top, Block, HClkRow,  MajorFrame, MinorFrame);
#elif ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
	Data = XHwIcap_SetupFarV5(Top, Block, HClkRow,  MajorFrame, MinorFrame);
#endif
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;

	/*
	 * Setup read data packet header.
	 * The frame will be preceeded by a dummy frame, and we need to read one
	 * extra word for V4 and V5 devices.
	 */
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	TotalWords = (InstancePtr->WordsPerFrame << 1) + 1;
#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex6 */
	TotalWords = (InstancePtr->WordsPerFrame << 1);
#endif
	/*
	 * Create Type one packet
	 */
	Packet = XHwIcap_Type1Read(XHI_FDRO) | TotalWords;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Write the data to the FIFO and initiate the transfer of data
	 * present in the FIFO to the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u32 *)&WriteBuffer[0],
			Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Wait till the write is done.
	 */
	while (XHwIcap_IsDeviceBusy(InstancePtr) != FALSE);


	/*
	 * Read the frame of the data including the NULL frame.
	 */
	Status = XHwIcap_DeviceRead(InstancePtr, FrameBuffer, TotalWords);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Send DESYNC command
	 */
	Status = XHwIcap_CommandDesync(InstancePtr);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
};
#elif (XHI_FAMILY == XHI_DEV_FAMILY_S6)
/****************************************************************************/
/**
*
* Reads one frame from the device and puts it in memory specified by the user.
*
* @param	InstancePtr - a pointer to the XHwIcap instance to be worked on.
* @param	Block - Block Address (XHI_FAR_CLB_BLOCK,
*		XHI_FAR_BRAM_BLOCK, XHI_FAR_BRAM_INT_BLOCK)
* @param	MajorFrame - selects the column
* @param	MinorFrame - selects frame inside column
* @param	FrameBuffer is a pointer to the memory where the frame read
*		from the device is stored
*
* @return	XST_SUCCESS else XST_FAILURE.
*
* @note		This is a blocking call.
*
*****************************************************************************/
int XHwIcap_DeviceReadFrame(XHwIcap *InstancePtr, long Block, long Row,
				long MajorFrame, long MinorFrame,
				u16 *FrameBuffer)
{
	int Status;
	u16 Packet;
	u16 TotalWords;
	u16 WriteBuffer[READ_FRAME_SIZE];
	u16 Index = 0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameBuffer != NULL);

	/*
	 * DUMMY and SYNC
	 */
	WriteBuffer[Index++] = XHI_DUMMY_PACKET;
	WriteBuffer[Index++] = XHI_SYNC_PACKET1;
	WriteBuffer[Index++] = XHI_SYNC_PACKET2;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Setup FAR register.
	 */
	Packet = XHwIcap_Type1Write(XHI_FAR_MAJ) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = (Block << XHI_BLOCK_SHIFT) |
				(Row << XHI_ROW_SHIFT) | MajorFrame;
	Packet = XHwIcap_Type1Write(XHI_FAR_MIN) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = MinorFrame;

	/*
	 * Setup CMD register to read configuration
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_CMD_RCFG;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	TotalWords = (InstancePtr->WordsPerFrame << 1) + 1;
	/*
	 * Create Type two packet for FDRO
	 */
	WriteBuffer[Index++] = XHwIcap_Type2Read(XHI_FDRO);
	WriteBuffer[Index++] = 0x0000;
	WriteBuffer[Index++] = TotalWords;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Write the data to the FIFO and initiate the transfer of data
	 * present in the FIFO to the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u16 *)&WriteBuffer[0],
					Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Wait till the write is done.
	 */
	while ((XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) &
					XHI_CR_WRITE_MASK);

	/*
	 * Read the frame of the data including the NULL frame.
	 */
	Status = XHwIcap_DeviceRead(InstancePtr, &FrameBuffer[0],
				TotalWords);

	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Send DESYNC command
	 */
	Status = XHwIcap_CommandDesync(InstancePtr);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	return Status;
}
#endif
