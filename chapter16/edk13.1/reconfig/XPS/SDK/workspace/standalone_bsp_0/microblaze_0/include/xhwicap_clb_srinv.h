/* $Id: xhwicap_clb_srinv.h,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap_clb_srinv.h
*
* This header file contains bit information about the CLB SRINV resource.
* This header file can be used with the XHwIcap_GetClbBits() and
* XHwIcap_SetClbBits() functions. This is only for Virtex4 devices.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/14/03 First release
* 1.01a bjb  04/10/06 V4 Support
* </pre>
*
*****************************************************************************/

#ifndef XHWICAP_CLB_SRINV_H_  /* prevent circular inclusions */
#define XHWICAP_CLB_SRINV_H_  /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/************************** Constant Definitions ****************************/


/**************************** Type Definitions ******************************/

#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* Virtex4 */
typedef struct {
	/**
	 * SRINV Resource values.
	 */
	const u8 SR_B[1];  /* Invert SR Line. */
	const u8 SR[1];    /* Do not Invert SR line. */

	/**
	 * Configure the SRINV mux (SR_B or SR).  This array indexed by
	 * slice  (0-3).
	 */
	const u8 RES[4][1][2];
} XHwIcap_ClbSrinv;

/***************** Macros (Inline Functions) Definitions ********************/


/************************** Function Prototypes *****************************/


/************************** Variable Definitions ****************************/

/**
 * This structure defines the SRINV mux
 */
const XHwIcap_ClbSrinv XHI_CLB_SRINV =
{
	/* SR_B*/
	{0},
	/* SR*/
	{1},
	/* RES*/
	{
		/* Slice 0. */
		{
			{24, 18}
		},
		/* Slice 1. */
		{
			{23, 18}
		},
		/* Slice 2. */
		{
			{26, 18}
		},
		/* Slice 3. */
		{
			{25, 18}
		}
	},

};

#else
#error Unsupported FPGA Family
#endif

#ifdef __cplusplus
}
#endif

#endif

