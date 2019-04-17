/* $Id: xhwicap_device_write_frame.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap_device_write_frame.c
*
* This file contains the function that writes the frame stored in the
* memory to the device (ICAP).
*
* @note none.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/20/03 First release
* 1.01a bjb  04/10/06 V4 Support
* 4.00a hvm  11/30/09 Added support for V6 and updated with HAL phase 1
*		      modifications
* 5.00a hvm  2/25/10  Added support for S6
* 5.01a hvm  07/06/10 Removed the code that adds wrong data byte before the
*		      CRC bytes in the XHwIcap_DeviceWriteFrame function for S6
*		      (CR560534)
*
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include "xhwicap.h"
#include <xil_types.h>
#include <xil_assert.h>

/************************** Constant Definitions ****************************/

#define READ_FRAME_SIZE 30

/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/


/************************** Variable Definitions ****************************/


/************************** Function Prototypes *****************************/
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5 ) ||\
	(XHI_FAMILY == XHI_DEV_FAMILY_V6))
/****************************************************************************/
/**
*
* Writes one frame from the specified buffer and puts it in the device
* (ICAP).
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	Top - top (0) or bottom (1) half of device
* @param	Block - Block Address (XHI_FAR_CLB_BLOCK,
* 		XHI_FAR_BRAM_BLOCK, XHI_FAR_BRAM_INT_BLOCK)
* @param	HClkRow - selects the HClk Row
* @param	MajorFrame - selects the column
* @param	MinorFrame - selects frame inside column
* @param	FrameData is a pointer to the frame that is to be written
*		to the device.
*
* @return	XST_SUCCESS else XST_FAILURE.
*
* @note		This is a blocking function.
*		This function is used in conjunction with the function
*		XHwIcap_DeviceReadFrame. This function is used to write back
*		the frame of data read using the XHwIcap_DeviceReadFrame.
*
*****************************************************************************/
int XHwIcap_DeviceWriteFrame(XHwIcap *InstancePtr, long Top, long Block,
				long HClkRow, long MajorFrame, long MinorFrame,
				u32 *FrameData)
{

	u32 Packet;
	u32 Data;
	u32 TotalWords;
	int Status;
	u32 WriteBuffer[READ_FRAME_SIZE];
	u32 Index =0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameData != NULL);


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
	Data = XHI_CMD_RCRC;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;


	/*
	 * Bypass CRC
	 */
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	Packet = XHwIcap_Type1Write(XHI_COR) | 1;
	Data = 0x10042FDD;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
#endif
	/*
	 * ID register
	 */
	Packet = XHwIcap_Type1Write(XHI_IDCODE) | 1;
	Data = InstancePtr->DeviceIdCode;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;


	/*
	 * Setup FAR
	 */
	Packet = XHwIcap_Type1Write(XHI_FAR) | 1;
#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* Virtex 4 */
	Data = XHwIcap_SetupFarV4(Top, Block, HClkRow,  MajorFrame, MinorFrame);
#elif ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
	Data = XHwIcap_SetupFarV5(Top, Block, HClkRow,  MajorFrame, MinorFrame);
#endif

	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;

	/*
	 * Setup CMD register - write configuration
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_WCFG;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Setup Packet header.
	 */
	TotalWords = InstancePtr->WordsPerFrame << 1;
	if (TotalWords < XHI_TYPE_1_PACKET_MAX_WORDS)  {
		/*
		 * Create Type 1 Packet.
		 */
		Packet = XHwIcap_Type1Write(XHI_FDRI) | TotalWords;
		WriteBuffer[Index++] = Packet;
	}
	else {

		/*
		 * Create Type 2 Packet.
		 */
		Packet = XHwIcap_Type1Write(XHI_FDRI);
		WriteBuffer[Index++] = Packet;

		Packet = XHI_TYPE_2_WRITE | TotalWords;
		WriteBuffer[Index++] = Packet;
	}


	/*
	 * Write the Header data into the FIFO and intiate the transfer of
	 * data present in the FIFO to the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u32 *)&WriteBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Write the modified frame data.
	 */
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	Status = XHwIcap_DeviceWrite(InstancePtr,
				(u32 *) &FrameData[InstancePtr->WordsPerFrame + 1],
				InstancePtr->WordsPerFrame);
#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex 6 */
	Status = XHwIcap_DeviceWrite(InstancePtr,
				(u32 *) &FrameData[InstancePtr->WordsPerFrame],
				InstancePtr->WordsPerFrame);
#endif
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Write out the pad frame. The pad frame was read from the device
	 * before the data frame.
	 */

#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	Status = XHwIcap_DeviceWrite(InstancePtr, (u32 *) &FrameData[1],
				    InstancePtr->WordsPerFrame);
#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex6 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u32 *) &FrameData[0],
				    InstancePtr->WordsPerFrame);
#endif
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Add CRC */
	Index = 0;
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	Packet = XHwIcap_Type1Write(XHI_CRC) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_DISABLED_AUTO_CRC;
#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex6 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_RCRC;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
#endif

	/* Park the FAR */
	Packet = XHwIcap_Type1Write(XHI_FAR) | 1;

#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* Virtex4 */
	Data = XHwIcap_SetupFarV4(0, 0, 3, 33, 0);
#elif ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
	Data = XHwIcap_SetupFarV5(0, 0, 3, 33, 0);
#endif

	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] =  Data;

	/* Add CRC */
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) || (XHI_FAMILY == XHI_DEV_FAMILY_V5))
	Packet = XHwIcap_Type1Write(XHI_CRC) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = XHI_DISABLED_AUTO_CRC;
#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex6 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_RCRC;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
#endif

	/*
	 * Intiate the transfer of data present in the FIFO to
	 * the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, &WriteBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Send DESYNC command
	 */
	Status = XHwIcap_CommandDesync(InstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
};

#elif (XHI_FAMILY == XHI_DEV_FAMILY_S6)
/****************************************************************************/
/**
*
* Writes one frame from the specified buffer and puts it in the device
* (ICAP).
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	Top - top (0) or bottom (1) half of device
* @param	Block - Block Address (XHI_FAR_CLB_BLOCK,
* 		XHI_FAR_BRAM_BLOCK, XHI_FAR_BRAM_INT_BLOCK)
* @param	HClkRow - selects the HClk Row
* @param	MajorFrame - selects the column
* @param	MinorFrame - selects frame inside column
* @param	FrameData is a pointer to the frame that is to be written
*		to the device.
*
* @return	XST_SUCCESS else XST_FAILURE.
*
* @note		This is a blocking function.
*		This function is used in conjunction with the function
*		XHwIcap_DeviceReadFrame. This function is used to write back
*		the frame of data read using the XHwIcap_DeviceReadFrame.
*
*****************************************************************************/
int XHwIcap_DeviceWriteFrame(XHwIcap *InstancePtr, long Block, long Row,
				long MajorFrame, long MinorFrame,
				u16 *FrameData)
{
	u16 Packet;
	u16 TotalWords;
	int Status;
	u16 WriteBuffer[READ_FRAME_SIZE];
	u16 Data;
	u16 Index =0;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameData != NULL);

	/*
	 * DUMMY and SYNC
	 */
	WriteBuffer[Index++] = XHI_DUMMY_PACKET;
	WriteBuffer[Index++] = XHI_SYNC_PACKET1;
	WriteBuffer[Index++] = XHI_SYNC_PACKET2;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Reset CRC
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_RCRC;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;


	/*
	 * Write the FLR
	 */
	Packet = XHwIcap_Type1Write(XHI_FLR) | 1;
	WriteBuffer[Index++] =  Packet ;
	WriteBuffer[Index++] =  0x430;

	/*
	 * ID register
	 */
	Packet = XHwIcap_Type1Write(XHI_IDCODE) | 2;
	WriteBuffer[Index++] = Packet;

	/*
	 * It is written wrongly in the document that only lower 16 bits are
	 * needed.The document will be updated. We need the complete 32 bit.
	 */
	Data = (u16)(InstancePtr->DeviceIdCode >> 16);
	WriteBuffer[Index++] = Data;
	Data = (u16)InstancePtr->DeviceIdCode;
	WriteBuffer[Index++] = Data;

	/*
	 * Bypass CRC
	 */
	Packet = XHwIcap_Type1Write(XHI_COR1) | 1;
	Data = XHI_COR1_DEFAULT;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;


	Packet = XHwIcap_Type1Write(XHI_COR2) | 1;
	Data = XHI_COR2_DEFAULT;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;

	/*
	 * Write the FAR MAJ and MIN address values
	 */
	Packet = XHwIcap_Type1Write(XHI_FAR_MAJ) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = (Block << XHI_BLOCK_SHIFT) |
				(Row << XHI_ROW_SHIFT) | MajorFrame;
	Packet = XHwIcap_Type1Write(XHI_FAR_MIN) | 1;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = MinorFrame;

	/*
	 * Setup CMD register - write configuration
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_WCFG;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;

	/*
	 * Setup Packet header.
	 */
	TotalWords = InstancePtr->WordsPerFrame << 1;
	/*
	 * Create Type 2 Packet.
	 */
	Packet = XHwIcap_Type2Write(XHI_FDRI);

	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = 0;
	WriteBuffer[Index++] = TotalWords;

	/*
	 * Write the Header data into the FIFO and intiate the transfer of
	 * data present in the FIFO to the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u16 *)&WriteBuffer[0],
					Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Write the modified frame data.
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr,
				(u16 *) &FrameData[InstancePtr->WordsPerFrame],
				InstancePtr->WordsPerFrame);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Write out the pad frame. The pad frame was read from the device
	 * before the data frame.
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, (u16 *) &FrameData[0],
				    InstancePtr->WordsPerFrame);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/* Disable CRC */
	Index = 0;
	WriteBuffer[Index++] = XHI_DISABLED_AUTO_CRC_ONE;
	WriteBuffer[Index++] = XHI_DISABLED_AUTO_CRC_TWO;

	/*
	 * Setup CMD register - write configuration
	 */
	Packet = XHwIcap_Type1Write(XHI_CMD) | 1;
	Data = XHI_CMD_LFRM;
	WriteBuffer[Index++] = Packet;
	WriteBuffer[Index++] = Data;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;
	WriteBuffer[Index++] = XHI_NOOP_PACKET;

	/*
	 * Intiate the transfer of data present in the FIFO to
	 * the ICAP device
	 */
	Status = XHwIcap_DeviceWrite(InstancePtr, &WriteBuffer[0], Index);
	if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}

	/*
	 * Send DESYNC command
	 */
	Status = XHwIcap_CommandDesync(InstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;

}
#endif

