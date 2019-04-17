/* $Id: xhwicap_l.h,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap_l.h
*
* This header file contains identifiers and basic driver functions (or
* macros) that can be used to access the device. Other driver functions
* are defined in xhwicap.h.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 2.00a sv   09/28/07 First release for the FIFO mode
* 3.00a sv   11/28/08 Added Abort bit definition in the Control Register
*		      Removed XHI_WFO_MAX_VACANCY and XHI_RFO_MAX_OCCUPANCY
*		      definitions.
* 3.01a sv   10/21/09 Corrected the IDCODE definitions for some of the
*                     V5 FX parts.
* 4.00a hvm  11/30/09 Added support for V6 and updated with HAL phase 1
*		      modifications
* 5.00a hvm  02/04/10 Added S6 Support
* </pre>
*
*****************************************************************************/
#ifndef XHWICAP_L_H_ /* prevent circular inclusions */
#define XHWICAP_L_H_ /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include <xil_types.h>
#include <xil_assert.h>
#include "xil_io.h"
#include "xhwicap_family.h"
/************************** Constant Definitions ****************************/

/******************************************************************/
/** @name Register Map
 *
 * Register offsets for the XHwIcap device.
 * @{
 */
#define XHI_GIER_OFFSET		0x1C  /**< Device Global Interrupt Enable Reg */
#define XHI_IPISR_OFFSET	0x20  /**< Interrupt Status Register */
#define XHI_IPIER_OFFSET	0x28  /**< Interrupt Enable Register */
#define XHI_WF_OFFSET		0x100 /**< Write FIFO */
#define XHI_RF_OFFSET		0x104 /**< Read FIFO */
#define XHI_SZ_OFFSET		0x108 /**< Size Register */
#define XHI_CR_OFFSET		0x10C /**< Control Register */
#define XHI_SR_OFFSET		0x110 /**< Status Register */
#define XHI_WFV_OFFSET		0x114 /**< Write FIFO Vacancy Register */
#define XHI_RFO_OFFSET		0x118 /**< Read FIFO Occupancy Register */

/* @} */


/** @name Device Global Interrupt Enable Register (GIER) bit definitions
 *
 * @{
 */
#define XHI_GIER_GIE_MASK      0x80000000 /**< Global Interrupt enable Mask */

/* @} */

/** @name HwIcap Device Interrupt Status/Enable Registers
 *
 * <b> Interrupt Status Register (IPISR) </b>
 *
 * This register holds the interrupt status flags for the device. These
 * bits are toggle on write.
 *
 * <b> Interrupt Enable Register (IPIER) </b>
 *
 * This register is used to enable interrupt sources for the device.
 * Writing a '1' to a bit in this register enables the corresponding Interrupt.
 * Writing a '0' to a bit in this register disables the corresponding Interrupt.
 *
 * IPISR/IPIER registers have the same bit definitions and are only defined
 * once.
 * @{
 */
#define XHI_IPIXR_RFULL_MASK	0x00000008 /**< Read FIFO Full */
#define XHI_IPIXR_WEMPTY_MASK	0x00000004 /**< Write FIFO Empty */
#define XHI_IPIXR_RDP_MASK	0x00000002 /**< Read FIFO half full */
#define XHI_IPIXR_WRP_MASK	0x00000001 /**< Write FIFO half full */
#define XHI_IPIXR_ALL_MASK	0x0000000F /**< Mask of all interrupts */

/* @} */

/** @name Control Register (CR)
 *
 * @{
 */
#define XHI_CR_SW_ABORT_MASK	0x00000010 /**< Abort current ICAP Read/Write */
#define XHI_CR_SW_RESET_MASK	0x00000008 /**< SW Reset Mask */
#define XHI_CR_FIFO_CLR_MASK	0x00000004 /**< FIFO Clear Mask */
#define XHI_CR_READ_MASK	0x00000002 /**< Read from ICAP to FIFO */
#define XHI_CR_WRITE_MASK	0x00000001 /**< Write from FIFO to ICAP */

/* @} */


/** @name Status Register (SR)
 *
 * @{
 */
#define XHI_SR_CFGERR_N_MASK	0x00000100 /**< Config Error Mask */
#define XHI_SR_DALIGN_MASK	0x00000080 /**< Data Alignment Mask */
#define XHI_SR_RIP_MASK		0x00000040 /**< Read back Mask */
#define XHI_SR_IN_ABORT_N_MASK	0x00000020 /**< Select Map Abort Mask */
#define XHI_SR_DONE_MASK	0x00000001 /**< Done bit Mask  */

/* @} */

/** @name IDCODE's for the Virtex4 Devices.
 *
 * @{
 */
#define XHI_XC4VLX15	0x01658093
#define XHI_XC4VLX25	0x0167C093
#define XHI_XC4VLX40	0x016A4093
#define XHI_XC4VLX60	0x016B4093
#define XHI_XC4VLX80	0x016D8093
#define XHI_XC4VLX100	0x01700093
#define XHI_XC4VLX160	0x01718093
#define XHI_XC4VLX200	0x01734093

#define XHI_XC4VSX25	0x02068093
#define XHI_XC4VSX35	0x02088093
#define XHI_XC4VSX55	0x020B0093

#define XHI_XC4VFX12	0x01E58093
#define XHI_XC4VFX20	0x01E64093
#define XHI_XC4VFX40	0x01E8C093
#define XHI_XC4VFX60	0x01EB4093
#define XHI_XC4VFX100	0x01EE4093
#define XHI_XC4VFX140	0x01F14093

#define XHI_V4_NUM_DEVICES	17

/* @} */

/** @name IDCODE's for the Virtex5 Devices.
 *
 * @{
 */
#define XHI_XC5VLX30	0x0286E093
#define XHI_XC5VLX50	0x02896093
#define XHI_XC5VLX85	0x028AE093
#define XHI_XC5VLX110	0x028D6093
#define XHI_XC5VLX220	0x0290C093
#define XHI_XC5VLX330	0x0295C093

#define XHI_XC5VLX30T	0x02A6E093
#define XHI_XC5VLX50T	0x02A96093
#define XHI_XC5VLX85T	0x02AAE093
#define XHI_XC5VLX110T	0x02AD6093
#define XHI_XC5VLX220T	0x02B0C093
#define XHI_XC5VLX330T	0x02B5C093

#define XHI_XC5VSX35T	0x02E72093
#define XHI_XC5VSX50T	0x02E9A093
#define XHI_XC5VSX95T	0x02ECE093

#define XHI_XC5VFX30T	0x03276093
#define XHI_XC5VFX70T	0x032C6093
#define XHI_XC5VFX100T	0x032D8093
#define XHI_XC5VFX130T	0x03300093
#define XHI_XC5VFX200T	0x03334093

#define XHI_V5_NUM_DEVICES	20
/* @} */

/** @name IDCODE's for the Virtex6 Devices.
 *
 * @{
 */

#define XHI_XC6VHX250T	0x042A2093
#define XHI_XC6VHX255T	0x042A4093
#define XHI_XC6VHX380T	0x042A8093
#define XHI_XC6VHX565T	0x042AC093

#define XHI_XC6VLX75T	0x04244093
#define XHI_XC6VLX130T	0x0424A093
#define XHI_XC6VLX195T	0x0424C093
#define XHI_XC6VLX240T 	0x04250093
#define XHI_XC6VLX365T	0x04252093
#define XHI_XC6VLX550T	0x04256093
#define XHI_XC6VLX760	0x0423A093
#define XHI_XC6VSX315T	0x04286093
#define XHI_XC6VSX475T	0x04288093

#define XHI_V6_NUM_DEVICES 	13

/* @} */

/** @name IDCODE's for the Spartan6 Devices.
 *
 * @{
 */

#define XHI_XC6SLX4	0x04000093
#define XHI_XC6SLX9	0x04001093
#define XHI_XC6SLX16	0x04002093
#define XHI_XC6SLX25	0x04004093
#define XHI_XC6SLX25T	0x04024093
#define XHI_XC6SLX45	0x04008093
#define XHI_XC6SLX45T	0x04028093
#define XHI_XC6SLX75	0x0400E093
#define XHI_XC6SLX75T	0x0402E093
#define XHI_XC6SLX100	0x04011093
#define XHI_XC6SLX100T	0x04031093
#define XHI_XC6SLX150	0x0401D093
#define XHI_XC6SLX150T	0x0403D093

#define XHI_S6_NUM_DEVICES	13

/* @} */

/**************************** Type Definitions ******************************/

/***************** Macros (Inline Functions) Definitions ********************/

#define XHwIcap_In32 Xil_In32

#define XHwIcap_Out32 Xil_Out32

/****************************************************************************/
/**
*
* Read from the specified HwIcap device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
*
* @return	The value read from the register.
*
* @note		C-Style signature:
*		u32 XHwIcap_ReadReg(u32 BaseAddress, u32 RegOffset);
*
******************************************************************************/
#define XHwIcap_ReadReg(BaseAddress, RegOffset) \
	XHwIcap_In32((BaseAddress) + (RegOffset))

/***************************************************************************/
/**
*
* Write to the specified HwIcap device register.
*
* @param	BaseAddress contains the base address of the device.
* @param	RegOffset contains the offset from the 1st register of the
*		device to select the specific register.
* @param	RegisterValue is the value to be written to the register.
*
* @return	None.
*
* @note		C-Style signature:
*		void XHwIcap_WriteReg(u32 BaseAddress, u32 RegOffset,
*					u32 RegisterValue);
******************************************************************************/
#define XHwIcap_WriteReg(BaseAddress, RegOffset, RegisterValue) \
	XHwIcap_Out32((BaseAddress) + (RegOffset), (RegisterValue))

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/


#ifdef __cplusplus
}
#endif

#endif         /* end of protection macro */


