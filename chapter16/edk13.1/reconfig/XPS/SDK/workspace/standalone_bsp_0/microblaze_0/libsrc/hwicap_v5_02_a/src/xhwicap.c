/* $Id: xhwicap.c,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
/****************************************************************************/
/**
*
* @file xhwicap.c
*
* This file contains the functions of the XHwIcap driver. See xhwicap.h for a
* detailed description of the driver.
*
* @note
*
* Virtex4, Virtex5, Virtex6 and Spartan6 devices are supported.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date      Changes
* ----- ---- -------- -------------------------------------------------------
* 2.00a sv   09/11/07  Initial version.
* 2.01a ecm  04/08/08  Updated data structures to include the V5FXT parts.
* 3.00a sv   11/28/08  Added the API for initiating Abort while reading/writing
*		       from the ICAP.
* 4.00a hvm  12/1/09   Added support for V6 and updated with HAL phase 1
*		       modifications
* 5.00a hvm  04/02/10  Added support for S6 device.
* 5.01a hvm  07/06/10  In XHwIcap_DeviceRead function, a read bit mask
*		       verification is added after all the data bytes are read
*		       from READ FIFO.The Verification of the read bit mask
*		       at the begining of reading of bytes is removed.
*
* </pre>
*
*****************************************************************************/

/***************************** Include Files ********************************/

#include <xil_types.h>
#include <xil_assert.h>
#include "xhwicap.h"

/************************** Constant Definitions ****************************/

/*
 * This is a list of arrays that contain information about columns interspersed
 * into the CLB columns.  These are DSP, IOB, DCM, and clock tiles.  When these
 * are crossed, the frame address must be incremeneted by an additional count
 * from the CLB column index.  The center tile is skipped twice because it
 * contains both a DCM and a GCLK tile that must be skipped.
 */
u16 XHI_EMPTY_SKIP_COLS[] = {0xFFFF};

u16 XHI_XC4VLX15_SKIP_COLS[] = {8, 12, 12, 0xFFFF};
u16 XHI_XC4VLX25_SKIP_COLS[] = {8, 14, 14, 0xFFFF};
u16 XHI_XC4VLX40_SKIP_COLS[] = {8, 18, 18, 0xFFFF};
u16 XHI_XC4VLX60_SKIP_COLS[] = {12, 26, 26, 0xFFFF};
u16 XHI_XC4VLX80_SKIP_COLS[] = {12, 28, 28, 0xFFFF};
u16 XHI_XC4VLX100_SKIP_COLS[] = {12, 32, 32, 0xFFFF};
u16 XHI_XC4VLX160_SKIP_COLS[] = {12, 44, 44, 0xFFFF};
u16 XHI_XC4VLX200_SKIP_COLS[] = {12, 58, 58, 0xFFFF};
u16 XHI_XC4VSX25_SKIP_COLS[] = {6, 14, 20, 20, 26, 34, 0xFFFF};
u16 XHI_XC4VSX35_SKIP_COLS[] = {6, 14, 20, 20, 26, 34, 0xFFFF};
u16 XHI_XC4VSX55_SKIP_COLS[] = {6, 10, 14, 18, 24, 24, 30, 34, 38,
                                  42, 0xFFFF};
u16 XHI_XC4VFX12_SKIP_COLS[] = {12, 12, 16, 0xFFFF};
u16 XHI_XC4VFX20_SKIP_COLS[] = {6, 18, 18, 22, 30, 0xFFFF};
u16 XHI_XC4VFX40_SKIP_COLS[] = {6, 26, 26, 38, 46, 0xFFFF};
u16 XHI_XC4VFX60_SKIP_COLS[] = {6, 18, 26, 26, 34, 46, 0xFFFF};
u16 XHI_XC4VFX100_SKIP_COLS[] = {6, 22, 34, 34, 46, 62, 0xFFFF};
u16 XHI_XC4VFX140_SKIP_COLS[] = {6, 22, 42, 42, 62, 78, 0xFFFF};


u16 XHI_XC5VLX30_SKIP_COLS[] = {4, 6, 14, 14, 22, 26, 0xFFFF};
u16 XHI_XC5VLX50_SKIP_COLS[] = {4, 6, 14, 14, 22, 26, 0xFFFF};
u16 XHI_XC5VLX85_SKIP_COLS[] = {4, 14, 16, 24, 24, 36, 46, 50, 0xFFFF};
u16 XHI_XC5VLX110_SKIP_COLS[] = {4, 14, 16, 24, 24, 36, 46, 50, 0xFFFF};
u16 XHI_XC5VLX220_SKIP_COLS[] = {4, 26, 28, 30, 32, 52, 52, 72, 78, 100,
				104, 0xFFFF};
u16 XHI_XC5VLX330_SKIP_COLS[] = {4, 26, 28, 30, 32, 52, 52, 72, 78, 100,
				104, 0xFFFF};
u16 XHI_XC5VLX30T_SKIP_COLS[] = {4, 6, 14, 14, 22, 26, 0xFFFF};
u16 XHI_XC5VLX50T_SKIP_COLS[] = {4, 6, 14, 14, 22, 26, 0xFFFF};
u16 XHI_XC5VLX85T_SKIP_COLS[] = {4, 14, 16, 24, 24, 36, 46, 50, 0xFFFF};
u16 XHI_XC5VLX110T_SKIP_COLS[] = {4, 14, 16, 24, 24, 36, 46, 50, 0xFFFF};
u16 XHI_XC5VLX220T_SKIP_COLS[] = {4, 26, 28, 30, 32, 52, 52, 72, 78, 100,
				104, 0xFFFF};
u16 XHI_XC5VLX330T_SKIP_COLS[] = {4, 26, 28, 30, 32, 52, 52, 72, 78, 100,
				104, 0xFFFF};
u16 XHI_XC5VSX35T_SKIP_COLS[] = {4, 6, 8, 10, 12, 14, 16, 18, 18, 20, 22,
				24, 26, 30, 0xFFFF};
u16 XHI_XC5VSX50T_SKIP_COLS[] = {4, 6, 8, 10, 12, 14, 16, 18, 18, 20, 22,
				24, 26, 30, 0xFFFF};
u16 XHI_XC5VSX95T_SKIP_COLS[] = {4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24,
				24, 26, 28, 30, 32, 34, 36, 38, 42, 0xFFFF};
u16 XHI_XC5VFX30T_SKIP_COLS[] = {4, 10, 16, 20, 20, 24, 26, 28, 30, 34, 0xFFFF};
u16 XHI_XC5VFX70T_SKIP_COLS[] = {4, 10, 16, 20, 20, 24, 26, 28, 30, 34, 0xFFFF};
u16 XHI_XC5VFX100T_SKIP_COLS[] = {4, 10, 16, 22, 24, 26, 28, 32, 32, 36,
				38, 40, 42, 48, 52, 0xFFFF};
u16 XHI_XC5VFX130T_SKIP_COLS[] = {4, 10, 16, 22, 24, 26, 28, 32, 32, 36,
				38, 40, 42, 48, 52, 0xFFFF};
u16 XHI_XC5VFX200T_SKIP_COLS[] = {4, 10, 16, 22, 28, 30, 32, 34, 38, 38, 42, 44,
				46, 48, 54, 60, 64, 0xFFFF};

/* V6 devices Skip column information */
u16 XHI_XC6VHX250T_SKIP_COLS[] = {5, 10, 13, 18, 27, 30, 35, 38, 43, 54, 59,
				64, 67, 72, 75, 84, 89, 92, 97, 105, 106,
				0xFFFF};

u16 XHI_XC6VHX255T_SKIP_COLS[] = {5, 10, 13, 18, 27, 30, 35, 38, 43, 54, 59,
				64, 67, 72, 75, 84, 89, 92, 97, 105, 106,
				0xFFFF};

u16 XHI_XC6VHX380T_SKIP_COLS[] = {5, 10, 13, 18, 27, 30, 35, 38, 43, 54, 59,
				64, 67, 72, 75, 84, 89, 92, 97, 105, 106,
				0xFFFF};

u16 XHI_XC6VHX565T_SKIP_COLS[] = {5, 10, 13, 22, 39, 48, 51, 56, 59, 64, 75,
				80, 85, 88, 93, 96, 105, 122, 131, 134,
				139, 147, 148, 0xFFFF};

u16 XHI_XC6VLX75T_SKIP_COLS[] = {5, 8, 13, 16, 19, 22, 25, 36, 41, 44, 47,
				50, 53, 58, 61, 69, 70, 0xFFFF};

u16 XHI_XC6VLX130T_SKIP_COLS[] = {5, 8, 13, 16, 19, 22, 25, 36, 41, 44, 47,
				50, 53, 58, 61, 69, 70, 0xFFFF};

u16 XHI_XC6VLX195T_SKIP_COLS[] = {5, 8, 13, 16, 25, 28, 33, 36, 41, 52, 57,
				62, 65, 70, 73, 82, 85, 90, 93, 101, 102,
				0xFFFF};

u16 XHI_XC6VLX240T_SKIP_COLS[] = {5, 8, 13, 16, 25, 28, 33, 36, 41, 52, 57,
				62, 65, 70, 73, 82, 85, 90, 93, 101, 102,
				0xFFFF};

u16 XHI_XC6VLX365T_SKIP_COLS[] = {5, 8, 21, 24, 33, 50, 53, 58, 69, 74, 79,
				82, 99, 108, 111, 124, 127, 132, 140, 141,
				0xFFFF};

u16 XHI_XC6VLX550T_SKIP_COLS[] = {5, 8, 21, 24, 33, 50, 53, 58, 69, 74, 79,
				82, 99, 108, 111, 124, 127, 132, 140, 141,
				0xFFFF};

u16 XHI_XC6VLX760_SKIP_COLS[] = {5, 8, 33, 36, 45, 70, 77, 80, 85, 96, 101,
				106, 109, 116, 141, 150, 153, 178, 181, 186,
				0xFFFF};

u16 XHI_XC6VSX315T_SKIP_COLS[] = {5, 8, 13, 16, 21, 24, 29, 32, 37, 40, 45,
				48, 51, 54, 59, 70, 75, 80, 83, 86, 89, 94,
				97, 102,105, 110, 113, 118, 121, 126, 129,
				137, 138, 0xFFFF};

u16 XHI_XC6VSX475T_SKIP_COLS[] = {5, 8, 13, 16, 21, 24, 29, 32, 37, 40, 45,
				48, 51, 54, 59, 70, 75, 80, 83, 86, 89, 94,
				97, 102,105, 110, 113, 118, 121, 126, 129,
				137, 138, 0xFFFF};


u16 XHI_XC6SLX4_SKIP_COLS[] = {3, 6, 9, 0xFFFF};

u16 XHI_XC6SLX9_SKIP_COLS[] = {3, 6, 9, 14, 0xFFFF};

u16 XHI_XC6SLX16_SKIP_COLS[] = {3, 6, 12, 19, 22, 0xFFFF};

u16 XHI_XC6SLX25_SKIP_COLS[] = {3, 6, 12, 19, 28, 31, 0xFFFF};

u16 XHI_XC6SLX45_SKIP_COLS[] = {3, 6, 12, 19, 26, 32, 35, 0xFFFF};

u16 XHI_XC6SLX45T_SKIP_COLS[] = {3, 6, 12, 19, 26, 32, 35, 0xFFFF};

u16 XHI_XC6SLX75_SKIP_COLS[] = {3, 8, 14, 21, 27, 33, 36, 39, 0xFFFF};

u16 XHI_XC6SLX75T_SKIP_COLS[] = {3, 8, 14, 21, 27, 33, 36, 39, 0xFFFF};

u16 XHI_XC6SLX100_SKIP_COLS[] = {3, 6, 11, 15, 21, 28, 35, 41, 46, 51, 54,
				 0xFFFF};

u16 XHI_XC6SLX100T_SKIP_COLS[] = {3, 6, 11, 15, 21, 28, 35, 41, 46, 51, 54,
				 0xFFFF};

u16 XHI_XC6SLX150_SKIP_COLS[] = {3, 6, 17, 21, 27, 40, 51, 57, 61, 70, 73,
				 0xFFFF};

u16 XHI_XC6SLX150T_SKIP_COLS[] = {3, 6, 17, 21, 27, 40, 51, 57, 61, 70, 73,
				 0xFFFF};

/* Device details loop up table  */

const DeviceDetails DeviceDetaillkup[] = {

	/* Virtex4 devices */

	{ XHI_XC4VLX15, 24, 64, 3, 1, 3, 0, 4, XHI_XC4VLX15_SKIP_COLS },

	{ XHI_XC4VLX25, 28, 96, 3, 1, 3, 0, 6, XHI_XC4VLX25_SKIP_COLS },

	{ XHI_XC4VLX40,	36, 128, 3, 1, 3, 0, 8, XHI_XC4VLX40_SKIP_COLS },

	{ XHI_XC4VLX60, 52, 128, 5, 1, 3, 0, 8, XHI_XC4VLX60_SKIP_COLS },

	{ XHI_XC4VLX80, 56, 160, 5, 1, 3, 0, 10, XHI_XC4VLX80_SKIP_COLS },

	{ XHI_XC4VLX100,64, 192, 5, 1, 3, 0, 12, XHI_XC4VLX100_SKIP_COLS },

	{ XHI_XC4VLX160, 88, 192, 6, 1, 3, 0, 12, XHI_XC4VLX160_SKIP_COLS },

	{ XHI_XC4VLX200, 116, 192, 7, 1, 3, 0, 12, XHI_XC4VLX200_SKIP_COLS },

	{ XHI_XC4VSX25,  40, 64, 8, 4, 3, 0, 4, XHI_XC4VSX25_SKIP_COLS },

	{ XHI_XC4VSX35,  40, 96, 8, 4, 3, 0, 6, XHI_XC4VSX35_SKIP_COLS },

	{ XHI_XC4VSX55, 48, 128, 10, 8, 3, 0, 8, XHI_XC4VSX55_SKIP_COLS },

	{ XHI_XC4VFX12, 24, 64, 3, 1, 3, 0, 4, XHI_XC4VFX12_SKIP_COLS },

	{ XHI_XC4VFX20, 36, 64, 5, 1, 3, 2, 4, XHI_XC4VFX20_SKIP_COLS },

	{ XHI_XC4VFX40, 52, 96, 7, 1, 3, 2, 6, XHI_XC4VFX40_SKIP_COLS },

	{ XHI_XC4VFX60, 52, 128, 8, 2, 3, 2, 8, XHI_XC4VFX60_SKIP_COLS },

	{ XHI_XC4VFX100, 68, 160, 10, 2, 3, 2, 10, XHI_XC4VFX100_SKIP_COLS },

	{ XHI_XC4VFX140, 84, 192, 12, 2, 3, 2, 12, XHI_XC4VFX140_SKIP_COLS },

	/* Virtex5 devices.  Array index is 17 for the first V5 device*/

	{ XHI_XC5VLX30, 30, 80, 2, 1, 2, 0, 4, XHI_XC5VLX30_SKIP_COLS },

	{ XHI_XC5VLX50, 30, 120, 2, 1, 2, 0, 6, XHI_XC5VLX50_SKIP_COLS },

	{ XHI_XC5VLX85, 54, 120, 4, 1, 2, 0, 6, XHI_XC5VLX85_SKIP_COLS },

	{ XHI_XC5VLX110, 54, 160, 4, 1, 2, 0, 8, XHI_XC5VLX110_SKIP_COLS },

	{ XHI_XC5VLX220, 108, 160, 6, 2, 2, 0, 8, XHI_XC5VLX220_SKIP_COLS },

	{ XHI_XC5VLX330, 108, 240, 6, 2, 2, 0, 12, XHI_XC5VLX330_SKIP_COLS },

	{ XHI_XC5VLX30T, 30, 80, 3, 1, 2, 1, 4, XHI_XC5VLX30T_SKIP_COLS },

	{ XHI_XC5VLX50T, 30, 120, 3, 1, 2, 1, 6, XHI_XC5VLX50T_SKIP_COLS },

	{ XHI_XC5VLX85T, 54, 120, 5, 1, 2, 1, 6, XHI_XC5VLX85T_SKIP_COLS },

	{ XHI_XC5VLX110T, 54, 160, 5, 1, 2, 1, 8, XHI_XC5VLX110T_SKIP_COLS },

	{ XHI_XC5VLX220T, 108, 160, 7, 2, 2, 1, 8, XHI_XC5VLX220T_SKIP_COLS },

	{ XHI_XC5VLX330T, 108, 240, 7, 2, 2, 1, 12, XHI_XC5VLX330T_SKIP_COLS },

	{ XHI_XC5VSX35T, 34, 80, 6, 6, 2, 1, 4, XHI_XC5VSX35T_SKIP_COLS },

	{ XHI_XC5VSX50T, 34, 120, 6, 6, 2, 1, 6, XHI_XC5VSX50T_SKIP_COLS },

	{ XHI_XC5VSX95T, 46, 160, 7, 10, 2, 1, 8, XHI_XC5VSX95T_SKIP_COLS },

	{ XHI_XC5VFX30T, 38, 80, 5, 2, 2, 1, 4, XHI_XC5VFX30T_SKIP_COLS },

	{ XHI_XC5VFX70T, 38, 160, 5, 2, 2, 1, 8, XHI_XC5VFX70T_SKIP_COLS },

	{ XHI_XC5VFX100T, 56, 160, 8, 4, 2, 1, 8, XHI_XC5VFX100T_SKIP_COLS },

	{ XHI_XC5VFX130T, 56, 200, 8, 4, 3, 1, 10, XHI_XC5VFX130T_SKIP_COLS },

	{ XHI_XC5VFX200T, 68, 240, 10, 4, 3, 1, 12, XHI_XC5VFX200T_SKIP_COLS },

	/* Virtex6 devices. Array index is 37 for the first V6 device */

	{ XHI_XC6VHX250T, 85, 240, 11, 6, 2, 2, 6, XHI_XC6VHX250T_SKIP_COLS },

	{ XHI_XC6VHX255T, 85, 240, 11, 6, 2, 2, 6, XHI_XC6VHX255T_SKIP_COLS },

	{ XHI_XC6VHX380T, 85, 360, 11, 6, 2, 2, 9, XHI_XC6VHX380T_SKIP_COLS },

	{ XHI_XC6VHX565T, 125, 360, 13, 6, 2, 2, 9, XHI_XC6VHX565T_SKIP_COLS },

	{ XHI_XC6VLX75T, 53, 120, 7, 5, 3, 1, 3, XHI_XC6VLX75T_SKIP_COLS },

	{ XHI_XC6VLX130T, 53, 200, 7, 6, 3, 1, 3, XHI_XC6VLX130T_SKIP_COLS },

	{ XHI_XC6VLX195T, 81, 200, 9, 8, 3, 1, 5, XHI_XC6VLX195T_SKIP_COLS },

	{ XHI_XC6VLX240T, 81, 240, 9, 8, 3, 1, 6, XHI_XC6VLX240T_SKIP_COLS },

	{ XHI_XC6VLX365T, 121, 240, 9, 6, 4, 1, 6, XHI_XC6VLX365T_SKIP_COLS },

	{ XHI_XC6VLX550T, 121, 360, 9, 6, 4, 1, 9, XHI_XC6VLX550T_SKIP_COLS },

	{ XHI_XC6VLX760, 121, 360, 10, 6, 4, 0, 9, XHI_XC6VLX760_SKIP_COLS },

	{ XHI_XC6VSX315T, 105, 240, 15, 14, 3, 1, 6, XHI_XC6VSX315T_SKIP_COLS},

	{ XHI_XC6VSX475T, 105, 360, 15, 14, 3, 1, 9, XHI_XC6VSX475T_SKIP_COLS},

	/* Spartan6 devices. Array index is 37 for the first S6 device */

	{ XHI_XC6SLX4, 5, 64, 1, 1, 0, 1, 0, XHI_XC6SLX4_SKIP_COLS },

	{ XHI_XC6SLX9, 12, 64, 2, 1, 0, 1, 0, XHI_XC6SLX9_SKIP_COLS },

	{ XHI_XC6SLX16, 19, 64, 2, 2, 0, 1, 0, XHI_XC6SLX16_SKIP_COLS },

	{ XHI_XC6SLX25, 27, 80, 3, 2, 0, 1, 0, XHI_XC6SLX25_SKIP_COLS },

	{ XHI_XC6SLX25T, 27, 80, 3, 2, 0, 1, 0, XHI_XC6SLX25_SKIP_COLS },

	{ XHI_XC6SLX45, 30, 128, 4, 2, 0, 1, 0, XHI_XC6SLX45_SKIP_COLS },

	{ XHI_XC6SLX45T, 30, 128, 4, 2, 0, 1, 0, XHI_XC6SLX45_SKIP_COLS },

	{ XHI_XC6SLX75, 34, 192, 4, 3, 0, 1, 0, XHI_XC6SLX75_SKIP_COLS },

	{ XHI_XC6SLX75T, 34, 192, 4, 3, 0, 1, 0, XHI_XC6SLX75T_SKIP_COLS },

	{ XHI_XC6SLX100, 45, 192, 6, 4, 0, 1, 0, XHI_XC6SLX100_SKIP_COLS },

	{ XHI_XC6SLX100T, 45, 192, 6, 4, 0, 1, 0, XHI_XC6SLX100T_SKIP_COLS },

	{ XHI_XC6SLX150, 64, 192, 6, 4, 0, 1, 0, XHI_XC6SLX150_SKIP_COLS },

	{ XHI_XC6SLX150T, 64, 192, 6, 4, 0, 1, 0, XHI_XC6SLX150_SKIP_COLS },

};


/**************************** Type Definitions ******************************/


/***************** Macros (Inline Functions) Definitions ********************/


/************************** Variable Definitions ****************************/


/************************** Function Prototypes *****************************/
static void StubStatusHandler(void *CallBackRef, u32 StatusEvent,
				u32 ByteCount);

/****************************************************************************/
/**
*
* This function initializes a specific XHwIcap instance.
* The IDCODE is read from the FPGA and based on the IDCODE the information
* about the resources in the FPGA is filled in the instance structure.
*
* The HwIcap device will be in put in a reset state before exiting this
* function.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	ConfigPtr points to the XHwIcap device configuration structure.
* @param	EffectiveAddr is the device base address in the virtual memory
*		address space. If the address translation is not used then the
*		physical address is passed.
*		Unexpected errors may occur if the address mapping is changed
*		after this function is invoked.
*
* @return	XST_SUCCESS else XST_FAILURE
*
* @note		None.
*
*****************************************************************************/
int XHwIcap_CfgInitialize(XHwIcap *InstancePtr, XHwIcap_Config *ConfigPtr,
				u32 EffectiveAddr)
{
	int Status;
	u32 DeviceIdCode;
	u32 TempDevId;
	u8 DeviceIdIndex;
	u8 NumDevices;
	u8 IndexCount;
	int DeviceFound = FALSE;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(ConfigPtr != NULL);

	/*
	 * Set some default values.
	 */
	InstancePtr->IsReady = FALSE;
	InstancePtr->IsTransferInProgress = FALSE;
	InstancePtr->IsPolled = TRUE; /* Polled Mode */

	/*
	 * Set the device base address and stub handler.
	 */
	InstancePtr->HwIcapConfig.BaseAddress = EffectiveAddr;
	InstancePtr->StatusHandler = (XHwIcap_StatusHandler) StubStatusHandler;

	/*
	 * Read the IDCODE from ICAP.
	 */

	/*
	 * Setting the IsReady of the driver temporarily so that
	 * we can read the IdCode of the device.
	 */
	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;


	/*
	 * Dummy Read of the IDCODE as the first data read from the
	 * ICAP has to be discarded (Due to the way the HW is designed).
	 */
	Status = XHwIcap_GetConfigReg(InstancePtr, XHI_IDCODE, &TempDevId);
	if (Status != XST_SUCCESS) {
		InstancePtr->IsReady = 0;
		return XST_FAILURE;
	}

	/*
	 * Read the IDCODE and mask out the version section of the DeviceIdCode.
	 */
	Status = XHwIcap_GetConfigReg(InstancePtr, XHI_IDCODE, &DeviceIdCode);
	if (Status != XST_SUCCESS) {
		InstancePtr->IsReady = 0;
		return XST_FAILURE;
	}
	DeviceIdCode = DeviceIdCode & XHI_DEVICE_ID_CODE_MASK;

#if (XHI_FAMILY != XHI_DEV_FAMILY_S6)
	Status = XHwIcap_CommandDesync(InstancePtr);
	InstancePtr->IsReady = 0;
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif

#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* Virtex4 */

	DeviceIdIndex = 0;
	NumDevices = XHI_V4_NUM_DEVICES;

#elif XHI_FAMILY == XHI_DEV_FAMILY_V5 /* Virtex5 */

	DeviceIdIndex = XHI_V4_NUM_DEVICES;
	NumDevices = XHI_V5_NUM_DEVICES;

#elif XHI_FAMILY == XHI_DEV_FAMILY_V6 /* Virtex6 */

	DeviceIdIndex = XHI_V4_NUM_DEVICES +  XHI_V5_NUM_DEVICES;
	NumDevices = XHI_V6_NUM_DEVICES;

#elif XHI_FAMILY == XHI_DEV_FAMILY_S6 /* Spartan6 */

	DeviceIdIndex = XHI_V4_NUM_DEVICES +  XHI_V5_NUM_DEVICES +
			XHI_V6_NUM_DEVICES;
	NumDevices = XHI_S6_NUM_DEVICES;

#endif
	/*
	 * Find the device index
	 */
	for (IndexCount = 0; IndexCount < NumDevices; IndexCount++) {

		if (DeviceIdCode == DeviceDetaillkup[DeviceIdIndex +
					IndexCount]. DeviceIdCode) {
			DeviceIdIndex += IndexCount;
			DeviceFound = TRUE;
			break;
		}
	}

	if (DeviceFound != TRUE) {

		return XST_FAILURE;

	}
	InstancePtr->DeviceIdCode = DeviceDetaillkup[DeviceIdIndex].
					DeviceIdCode;

	InstancePtr->Rows = DeviceDetaillkup[DeviceIdIndex].Rows;
	InstancePtr->Cols = DeviceDetaillkup[DeviceIdIndex].Cols;
	InstancePtr->BramCols = DeviceDetaillkup[DeviceIdIndex].BramCols;

	InstancePtr->DSPCols = DeviceDetaillkup[DeviceIdIndex].DSPCols;
	InstancePtr->IOCols = DeviceDetaillkup[DeviceIdIndex].IOCols;
	InstancePtr->MGTCols = DeviceDetaillkup[DeviceIdIndex].MGTCols;

	InstancePtr->HClkRows = DeviceDetaillkup[DeviceIdIndex].HClkRows;
	InstancePtr->SkipCols = DeviceDetaillkup[DeviceIdIndex].SkipCols;

	InstancePtr->BytesPerFrame = XHI_NUM_FRAME_BYTES;

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
	/*
	 * In Spartan6 devices the word is defined as 16 bit
	 */
	InstancePtr->WordsPerFrame = (InstancePtr->BytesPerFrame/2);
#else
	InstancePtr->WordsPerFrame = (InstancePtr->BytesPerFrame/4);
#endif
	InstancePtr->ClbBlockFrames = (4 +22*2 + 4*2 + 22*InstancePtr->Cols);
	InstancePtr->BramBlockFrames = (64*InstancePtr->BramCols);
	InstancePtr->BramIntBlockFrames = (22*InstancePtr->BramCols);

	InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

	/*
	 * Reset the device.
	 */
	XHwIcap_Reset(InstancePtr);

	return XST_SUCCESS;
} /* end XHwIcap_CfgInitialize() */


/****************************************************************************/
/**
*
* This function writes the given user data to the Write FIFO in both the
* polled mode and the interrupt mode and starts the transfer of the data to
* the ICAP device.
*
* In the polled mode, this function will write the specified number of words
* into the FIFO before returning.
*
* In the interrupt mode, this function will write the words upto the size
* of the Write FIFO and starts the transfer, then subsequent transfer of the
* data is performed by the interrupt service routine until the entire buffer
* has been transferred. The status callback function is called when the entire
* buffer has been sent.
* In order to use interrupts, it is necessary for the user to connect the driver
* interrupt handler, XHwIcap_IntrHandler(), to the interrupt system of
* the application and enable the interrupts associated with the Write FIFO.
* The user has to enable the interrupts each time this function is called
* using the XHwIcap_IntrEnable macro.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	FrameBuffer is a pointer to the data to be written to the
*			ICAP device.
* @param	NumWords is the number of words (16 bit for S6 and 32 bit
*		for all other devices)to write to the ICAP device.
*
* @return	XST_SUCCESS or XST_FAILURE
*
* @note		This function is a blocking for the polled mode of operation
*		and is non-blocking for the interrupt mode of operation.
*		Use the function XHwIcap_DeviceWriteFrame for writing a frame
*		of data to the ICAP device.
*
*****************************************************************************/
#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
int XHwIcap_DeviceWrite(XHwIcap *InstancePtr, u16 *FrameBuffer, u32 NumWords)
#else
int XHwIcap_DeviceWrite(XHwIcap *InstancePtr, u32 *FrameBuffer, u32 NumWords)
#endif
{

	u32 WrFifoVacancy;
	u32 IntrStatus;

	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameBuffer != NULL);
	Xil_AssertNonvoid(NumWords > 0);

	/*
	 * Make sure that the last Read/Write by the driver is complete.
	 */
	if (XHwIcap_IsTransferDone(InstancePtr) == FALSE) {
		return XST_FAILURE;
	}

	/*
	 * Check if the ICAP device is Busy with the last Read/Write
	 */
	if (XHwIcap_IsDeviceBusy(InstancePtr) == TRUE) {
		return XST_FAILURE;
	}

	/*
	 * Set the flag, which will be cleared when the transfer
	 * is entirely done from the FIFO to the ICAP.
	 */
	InstancePtr->IsTransferInProgress = TRUE;


	/*
	 * Disable the Global Interrupt.
	 */
	XHwIcap_IntrGlobalDisable(InstancePtr);


	/*
	 * Set up the buffer pointer and the words to be transferred.
	 */
	InstancePtr->SendBufferPtr = FrameBuffer;
	InstancePtr->RequestedWords = NumWords;
	InstancePtr->RemainingWords = NumWords;


	/*
	 * Fill the FIFO with as many words as it will take (or as many as we
	 * have to send).
	 */
	WrFifoVacancy = XHwIcap_GetWrFifoVacancy(InstancePtr);
	while ((WrFifoVacancy != 0) &&
	       (InstancePtr->RemainingWords > 0)) {

		XHwIcap_FifoWrite(InstancePtr, *InstancePtr->SendBufferPtr);
		InstancePtr->RemainingWords--;
		WrFifoVacancy--;
		InstancePtr->SendBufferPtr++;
	}


	/*
	 * Start the transfer of the data from the FIFO to the ICAP device.
	 */
	XHwIcap_StartConfig(InstancePtr);

	while ((XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) &
					XHI_CR_WRITE_MASK);

	/*
	 * Check if there is more data to be written to the ICAP
	 */
	if (InstancePtr->RemainingWords != NULL){

		/*
		 * Check whether it is polled or interrupt mode of operation.
		 */
		if (InstancePtr->IsPolled == FALSE) { /* Interrupt Mode */

			/*
			 * If it is interrupt mode of operation then the
			 * transfer of the remaining data will be done in the
			 * interrupt handler.
			 */

			/*
			 * Clear the interrupt status of the earlier interrupts
			 */
			IntrStatus  = XHwIcap_IntrGetStatus(InstancePtr);
			XHwIcap_IntrClear(InstancePtr, IntrStatus);


			/*
			 * Enable the interrupts by enabling the
			 * Global Interrupt.
			 */
			XHwIcap_IntrGlobalEnable(InstancePtr);

		}
		else { /* Polled Mode */

			while (InstancePtr->RemainingWords > 0) {

				WrFifoVacancy =
					XHwIcap_GetWrFifoVacancy(InstancePtr);
				while ((WrFifoVacancy != 0) &&
				       (InstancePtr->RemainingWords > 0)) {
					XHwIcap_FifoWrite(InstancePtr,
						*InstancePtr->SendBufferPtr);

					InstancePtr->RemainingWords--;
					WrFifoVacancy--;
					InstancePtr->SendBufferPtr++;
				}

				XHwIcap_StartConfig(InstancePtr);
				while ((XHwIcap_ReadReg(
					InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) & XHI_CR_WRITE_MASK);



			}

			/*
		 	 * Clear the flag to indicate the write has been done
		 	 */
			InstancePtr->IsTransferInProgress = FALSE;
			InstancePtr->RequestedWords = 0x0;
		}

	} else {

		/*
		 * Clear the flag to indicate the write has been done
		 */
		InstancePtr->IsTransferInProgress = FALSE;
		InstancePtr->RequestedWords = 0x0;
	}

	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* This function reads the specified number of words from the ICAP device in
* the polled mode. Interrupt mode is not supported in reading data from the
* ICAP device.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	FrameBuffer is a pointer to the memory where the frame read
*		from the ICAP device is stored.
* @param	NumWords is the number of words (16 bit for S6 and 32 bit for
* 			all other devices) to write to the ICAP device.
*
* @return
*		- XST_SUCCESS if the specified number of words have been read
*		from the ICAP device
*		- XST_FAILURE if the device is busy with the last Read/Write, or
*		if the requested number of words have not been read from the
*		ICAP device, or there is a timeout.
*
* @note		This is a blocking function.
*
*****************************************************************************/
#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
int XHwIcap_DeviceRead(XHwIcap *InstancePtr, u16 *FrameBuffer, u32 NumWords)
#else
int XHwIcap_DeviceRead(XHwIcap *InstancePtr, u32 *FrameBuffer, u32 NumWords)
#endif
{

	u32 Retries = 0;
#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)

	u16 *Data = FrameBuffer;
#else
	u32 *Data = FrameBuffer;
#endif
	u32 RdFifoOccupancy = 0;

	/*
	 * Assert validates the input arguments
	 */
	Xil_AssertNonvoid(InstancePtr != NULL);
	Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);
	Xil_AssertNonvoid(FrameBuffer != NULL);
	Xil_AssertNonvoid(NumWords > 0);

	/*
	 * Make sure that the last Read/Write by the driver is complete.
	 */
	if (XHwIcap_IsTransferDone(InstancePtr) == FALSE) {
		return XST_FAILURE;
	}

	/*
	 * Check if the ICAP device is Busy with the last Write/Read
	 */
	if (XHwIcap_IsDeviceBusy(InstancePtr) == TRUE) {
		return XST_FAILURE;
	}

	/*
	 * Set the flag, which will be cleared by the driver
	 * when the transfer is entirely done.
	 */
	InstancePtr->IsTransferInProgress = TRUE;
	InstancePtr->RequestedWords = NumWords;
	InstancePtr->RemainingWords = NumWords;

	XHwIcap_SetSizeReg(InstancePtr, NumWords);
	XHwIcap_StartReadBack(InstancePtr);

	/*
	 * Read the data from the Read FIFO into the buffer provided by
	 * the user.
	 */
	/* As long as there is still data to read... */
	while (InstancePtr->RemainingWords > 0) {
		/* Wait until we have some data in the fifo. */
		while(RdFifoOccupancy == 0) {
			RdFifoOccupancy =
			XHwIcap_GetRdFifoOccupancy(InstancePtr);

			Retries++;
			if (Retries > XHI_MAX_RETRIES) {
				break;
			}
		}

		/* Read the data from the Read FIFO. */
		while((RdFifoOccupancy != 0) &&
				(InstancePtr->RemainingWords > 0)) {
			*Data++ = XHwIcap_FifoRead(InstancePtr);
			InstancePtr->RemainingWords--;
			RdFifoOccupancy--;
	   }
	}

	while ((XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
					XHI_CR_OFFSET)) &
					XHI_CR_READ_MASK);
	/*
	 * If the requested number of words have not been read from
	 * the device then indicate failure.
	 */
	if (InstancePtr->RemainingWords != 0){
		return XST_FAILURE;
	}


	InstancePtr->IsTransferInProgress = FALSE;
	InstancePtr->RequestedWords = 0x0;

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function forces the software reset of the complete HWICAP device.
* All the registers will return to the default value and the FIFO is also
* flushed as a part of this software reset.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XHwIcap_Reset(XHwIcap *InstancePtr)
{
	u32 RegData;
	/*
	 * Assert the arguments.
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Reset the device by setting/clearing the RESET bit in the
	 * Control Register.
	 */
	RegData = XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
				XHI_CR_OFFSET);

	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress, XHI_CR_OFFSET,
				RegData | XHI_CR_SW_RESET_MASK);

	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress, XHI_CR_OFFSET,
				RegData & (~ XHI_CR_SW_RESET_MASK));

}

/*****************************************************************************/
/**
*
* This function flushes the FIFOs in the device.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XHwIcap_FlushFifo(XHwIcap *InstancePtr)
{
	u32 RegData;
	/*
	 * Assert the arguments.
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Flush the FIFO by setting/clearing the FIFO Clear bit in the
	 * Control Register.
	 */
	RegData = XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
				XHI_CR_OFFSET);

	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress, XHI_CR_OFFSET,
				RegData | XHI_CR_FIFO_CLR_MASK);

	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress, XHI_CR_OFFSET,
				RegData & (~ XHI_CR_FIFO_CLR_MASK));

}

/*****************************************************************************/
/**
*
* This function initiates the Abort Sequence by setting the Abort bit in the
* control register.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XHwIcap_Abort(XHwIcap *InstancePtr)
{
	u32 RegData;

	/*
	 * Assert the arguments.
	 */
	Xil_AssertVoid(InstancePtr != NULL);
	Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

	/*
	 * Initiate the Abort sequence in the ICAP by setting the Abort bit in
	 * the Control Register.
	 */
	RegData = XHwIcap_ReadReg(InstancePtr->HwIcapConfig.BaseAddress,
				XHI_CR_OFFSET);

	XHwIcap_WriteReg(InstancePtr->HwIcapConfig.BaseAddress, XHI_CR_OFFSET,
				RegData | XHI_CR_SW_ABORT_MASK);

}

/*****************************************************************************/
/**
*
* This is a stub for the status callback. The stub is here in case the upper
* layers forget to set the handler.
*
* @param	CallBackRef is a pointer to the upper layer callback reference
* @param	StatusEvent is the event that just occurred.
* @param	WordCount is the number of words (32 bit) transferred up until
*		the event occurred.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static void StubStatusHandler(void *CallBackRef, u32 StatusEvent, u32 ByteCount)
{
	Xil_AssertVoidAlways();
}

