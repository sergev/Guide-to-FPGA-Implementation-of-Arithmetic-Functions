/* $Id: xhwicap.h,v 1.1.2.1 2010/10/08 10:21:01 vidhum Exp $ */
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
* @file xhwicap.h
*
* The Xilinx XHwIcap driver supports the Xilinx Hardware Internal Configuration
* Access Port (HWICAP) device.
*
* The HWICAP device is used for reconfiguration of select FPGA resources
* as well as loading partial bitstreams from the system memory through the
* Internal Configuration Access Port (ICAP).
*
* The source code for the XHwIcap_SetClbBits and XHwIcap_GetClbBits
* functions  are not included. These functions are delivered as .o
* files. These files have been compiled using gcc version 4.1.1.
* Libgen uses the appropriate .o files for the target processor.
*
* <b> Initialization and Configuration </b>
*
* The device driver enables higher layer software (e.g., an application) to
* communicate to the HWICAP device.
*
* XHwIcap_CfgInitialize() API is used to initialize the HWICAP device.
* The user needs to first call the XHwIcap_LookupConfig() API which returns
* the Configuration structure pointer which is passed as a parameter to the
* XHwIcap_CfgInitialize() API.
*
* <b> Interrupts </b>
*
* The driver provides an interrupt handler XHwIcap_IntrHandler for handling
* the interrupt from the HWICAP device. The users of this driver have to
* register this handler with the interrupt system and provide the callback
* functions. The callback functions are invoked by the interrupt handler based
* on the interrupt source.
*
* The driver supports interrupt mode only for writing to the ICAP device and
* is NOT supported for reading from the ICAP device.
*
* <b> Virtual Memory </b>
*
* This driver supports Virtual Memory. The RTOS is responsible for calculating
* the correct device base address in Virtual Memory space.
*
* <b> Threads </b>
*
* This driver is not thread safe. Any needs for threads or thread mutual
* exclusion must be satisfied by the layer above this driver.
*
* <b> Asserts </b>
*
* Asserts are used within all Xilinx drivers to enforce constraints on argument
* values. Asserts can be turned off on a system-wide basis by defining, at
* compile time, the NDEBUG identifier. By default, asserts are turned on and it
* is recommended that users leave asserts on during development.
*
* <b> Building the driver </b>
*
* The XHwIcap driver is composed of several source files. This allows the user
* to build and link only those parts of the driver that are necessary.
*
*
* @note
*
* There are a few items to be aware of when using this driver:
* 1) Only Virtex4, Virtex5, Virtex6 and Spartan6 devices are supported.
* 2) The ICAP port is disabled when the configuration mode, via the MODE pins,
* is set to Boundary Scan/JTAG. The ICAP is enabled in all other configuration
* modes and it is possible to configure the device via JTAG in all
* configuration modes.
* 3) Reading or writing to columns containing SRL16's or LUT RAM's can cause
* corruption of data in those elements. Avoid reading or writing to columns
* containing SRL16's or LUT RAM's.
* 4) Only the LUT and SRL are accesible, all other features of the slice are
* not available through this interface.
* 5) The Spartan6 devices access is 16-bit access and is 32 bit for all
* other devices.
*
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/17/03 First release
* 1.01a bjb  04/10/06 V4 Support
* 2.00a sv   09/28/07 First release for the FIFO mode
* 2.01a ecm  04/08/08 Updated data structures to include the V5FXT parts.
* 3.00a sv   11/28/08 Added the API for initiating Abort while reading/writing
*		      from the ICAP.
* 3.01a sv   10/21/09 Corrected the IDCODE definitions for some of the
*                     V5 FX parts in xhwicap_l.h. Corrected the V5 BOOTSTS and
*                     CTL_1 Register definitions in xhwicap_i.h file as they
*                     were wrongly defined.
* 4.00a hvm  12/1/09  Added support for V6 and updated with HAL phase 1
*		      modifications
* 5.00a hvm  04/02/10 Added S6 device support
* 5.01a hvm  07/06/10 In XHwIcap_DeviceRead function, a read bit mask
*		      verification is added after all the data bytes are read
*		      from READ FIFO.The Verification of the read bit mask
*		      at the begining of reading of bytes is removed.
*		      Removed the code that adds wrong data byte before the
*		      CRC bytes in the XHwIcap_DeviceWriteFrame function for S6
*		      (CR560534).
*
* </pre>
*
*****************************************************************************/
#ifndef XHWICAP_H_ /* prevent circular inclusions */
#define XHWICAP_H_ /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files ********************************/

#include "xhwicap_i.h"
#include "xhwicap_l.h"
#include <xstatus.h>

/************************** Constant Definitions ****************************/
/************************** Type Definitions ********************************/

/**************************** Type Definitions *******************************/

/**
 * The handler data type allows the user to define a callback function to
 * handle the asynchronous processing of the HwIcap driver. The application
 * using this driver is expected to define a handler of this type to support
 * interrupt driven mode. The handler executes in an interrupt context such
 * that minimal processing should be performed.
 *
 * @param 	CallBackRef is a callback reference passed in by the application
 *		layer when setting the callback functions, and passed back to the
 *		the upper layer when the callback is invoked. Its type is
 *		unimportant to the driver component, so it is a void pointer.
 * @param 	StatusEvent indicates one or more status events that occurred.
 *		See the XHwIcap_SetInterruptHandler for details on the status
 *		events that can be passed in the callback.
 * @param	WordCount indicates how many words of data were successfully
 *		transferred.  This may be less than the number of words
 *		requested if there was an error.
 */
typedef void (*XHwIcap_StatusHandler) (void *CallBackRef, u32 StatusEvent,
					u32 WordCount);


/**
 * This typedef contains configuration information for the device.
 */
typedef struct {
	u16 DeviceId;		/**< Device ID  of device */
	u32 BaseAddress;	/**< Register base address */

} XHwIcap_Config;

typedef struct  {

	u32 DeviceIdCode;	     /**< IDCODE of targeted device */
	u32 Cols;		     /**< Number of CLB cols */
	u32 Rows;		     /**< Number of CLB rows */
	u32 BramCols;		     /**< Number of BRAM cols */
	u8  DSPCols;		     /**< Number of DSP cols for V4/V5/V6 */
	u8  IOCols;		     /**< Number of IO cols for V4/V5/V6 */
	u8  MGTCols;		     /**< Number of MGT cols for V4/V5/V6 */
	u8  HClkRows;		     /**< Number of HClk cols for V4/V5/V6 */
	u16 *SkipCols;		     /**< Columns to skip for CLB Col */

} DeviceDetails;

 /**
  * The XHwIcap driver instance data. The user is required to allocate a
  * variable of this type for every HwIcap device in the system. A pointer
  * to a variable of this type is then passed to the driver API functions.
  */
typedef struct {
	XHwIcap_Config HwIcapConfig; /**< Instance of the config struct. */
	u32 IsReady;		     /**< Device is initialized and ready */
	int IsPolled;		     /**< Device is in polled mode */
	u32 DeviceIdCode;	     /**< IDCODE of targeted device */
	u32 Rows;		     	/**< Number of CLB rows */
	u32 Cols;		     		/**< Number of CLB cols */
	u32 BramCols;		     /**< Number of BRAM cols */
	u32 BytesPerFrame;	     /**< Number of Bytes per minor Frame */
	u32 WordsPerFrame;	     /**< Number of Words per minor Frame */
	u32 ClbBlockFrames; 	     /**< Number of CLB type minor Frames */
	u32 BramBlockFrames;	     /**< Number of Bram type minor Frames */
	u32 BramIntBlockFrames;	     /**< Number of BramInt type minor Frames */
	u8  HClkRows;		     /**< Number of HClk cols for V4/V5 */
	u8  DSPCols;		     /**< Number of DSP cols for V4/V5 */
	u8  IOCols;		     	/**< Number of IO cols for V4/V5 */
	u8  MGTCols;		     /**< Number of MGT cols for V4/V5 */
	u16 *SkipCols;		     /**< Columns to skip for CLB Col
				      			**  calculations */

#if XHI_FAMILY == XHI_DEV_FAMILY_S6 /* If Spartan6 device */
	u16 *SendBufferPtr;	     /**< Buffer to write to the ICAP device */
#else
	u32 *SendBufferPtr;	     /**< Buffer to write to the ICAP device */

#endif
	u32 RequestedWords;	     /**< Number of Words to transfer  */
	u32 RemainingWords; 	     /**< Number of Words left to transfer  */
	int IsTransferInProgress;    /**< A transfer is in progress */
	XHwIcap_StatusHandler StatusHandler; /**< Interrupt handler callback */
	void *StatusRef;	     /**< Callback ref. for the interrupt
								* handler */

} XHwIcap;

/***************** Macro (Inline Functions) Definitions *********************/


/****************************************************************************/
/**
*
* Write data to the Write FIFO.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	Data is the 32-bit value to be written to the FIFO.
*
* @return	None.
*
* @note		C-style Signature:
* 		void XHwIcap_FifoWrite(XHwIcap *InstancePtr, u32 Data);
*
*****************************************************************************/
#define XHwIcap_FifoWrite(InstancePtr, Data) 				\
	(XHwIcap_WriteReg(((InstancePtr)->HwIcapConfig.BaseAddress),	\
		XHI_WF_OFFSET, (Data)))

/****************************************************************************/
/**
*
* Read data from the Read FIFO.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	The 32-bit Data read from the FIFO.
*
* @note		C-style Signature:
* 		u32 XHwIcap_FifoRead(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_FifoRead(InstancePtr) 					\
(XHwIcap_ReadReg(((InstancePtr)->HwIcapConfig.BaseAddress), XHI_RF_OFFSET))

/****************************************************************************/
/**
*
* Set the number of words to be read from the Icap in the Size register.
*
* The Size Register holds the number of 32 bit words to transfer from the
* the Icap to the Read FIFO of the HwIcap device.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	Data is the size in words.
*
* @return	None.
*
* @note		C-style Signature:
*		void XHwIcap_SetSizeReg(XHwIcap *InstancePtr, u32 Data);
*
*****************************************************************************/
#define XHwIcap_SetSizeReg(InstancePtr, Data) \
	(XHwIcap_WriteReg(((InstancePtr)->HwIcapConfig.BaseAddress), \
		XHI_SZ_OFFSET, (Data)))

/****************************************************************************/
/**
*
* Get the contents of the Control register.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	A 32-bit value representing the contents of the Control
*		register.
*
* @note		u32 XHwIcap_GetControlReg(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_GetControlReg(InstancePtr) \
 (XHwIcap_ReadReg(((InstancePtr)->HwIcapConfig.BaseAddress), XHI_CR_OFFSET))


/****************************************************************************/
/**
*
* Set the Control Register to initiate a configuration (write) to the device.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		C-style Signature:
*		void XHwIcap_StartConfig(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_StartConfig(InstancePtr) \
 (XHwIcap_WriteReg(((InstancePtr)->HwIcapConfig.BaseAddress), XHI_CR_OFFSET, \
 	(XHwIcap_GetControlReg(InstancePtr) & 				      \
 	(~ XHI_CR_READ_MASK)) | XHI_CR_WRITE_MASK))


/****************************************************************************/
/**
*
* Set the Control Register to initiate a ReadBack from the device.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	None.
*
* @note		C-style Signature:
*		void XHwIcap_StartReadBack(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_StartReadBack(InstancePtr) \
 (XHwIcap_WriteReg(((InstancePtr)->HwIcapConfig.BaseAddress) , XHI_CR_OFFSET, \
 	(XHwIcap_GetControlReg(InstancePtr) & 				       \
 	(~ XHI_CR_WRITE_MASK)) | XHI_CR_READ_MASK))


/****************************************************************************/
/**
*
* Get the contents of the status register.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return	A 32-bit value representing the contents of the status register.
*
* @note		u32 XHwIcap_GetStatusReg(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_GetStatusReg(InstancePtr) \
(XHwIcap_ReadReg(((InstancePtr)->HwIcapConfig.BaseAddress), XHI_SR_OFFSET))

/****************************************************************************/
/**
*
* This macro checks if the last Read/Write of the data to the Read/Write FIFO
* of the HwIcap device is completed.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return
*		- TRUE if the Read/Write to the FIFO's is completed.
*		- FALSE if the Read/Write to the FIFO's is NOT completed..
*
* @note		C-Style signature:
*		int XHwIcap_IsTransferDone(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_IsTransferDone(InstancePtr)			\
	((InstancePtr->IsTransferInProgress) ? FALSE : TRUE)

/****************************************************************************/
/**
*
* This macro checks if the last Read/Write to the ICAP device in the FPGA
* is completed.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
*
* @return
*		- TRUE if the last Read/Write(Config) to the ICAP is NOT
*		completed.
*		- FALSE if the Read/Write(Config) to the ICAP is completed..
*
* @note		C-Style signature:
*		int XHwIcap_IsDeviceBusy(XHwIcap *InstancePtr);
*
*****************************************************************************/
#define XHwIcap_IsDeviceBusy(InstancePtr)			\
	((XHwIcap_GetStatusReg(InstancePtr) & XHI_SR_DONE_MASK) ? \
				FALSE : TRUE)

/******************************************************************************/
/**
*
* This macro enables the global interrupt in the Global Interrupt Enable
* Register (GIER) so that the interrupt output from the HwIcap device is
* enabled. Interrupts enabled using XHwIcap_IntrEnable() will not occur until
* the global interrupt enable bit is set by using this macro.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	None.
*
* @note		C-Style signature:
*		void XHwIcap_IntrGlobalEnable(InstancePtr)
*
******************************************************************************/
#define XHwIcap_IntrGlobalEnable(InstancePtr)				\
	XHwIcap_WriteReg((InstancePtr)->HwIcapConfig.BaseAddress,	\
				XHI_GIER_OFFSET, XHI_GIER_GIE_MASK)

/******************************************************************************/
/**
*
* This macro disables the global interrupt in the Global Interrupt Enable
* Register (GIER) so that the interrupt output from the HwIcap device is
* disabled.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	None.
*
* @note		C-Style signature:
*		void XHwIcap_IntrGlobalDisable(InstancePtr)
*
******************************************************************************/
#define XHwIcap_IntrGlobalDisable(InstancePtr)				\
	XHwIcap_WriteReg((InstancePtr)->HwIcapConfig.BaseAddress,	\
				XHI_GIER_OFFSET, 0x0)

/******************************************************************************/
/**
*
* This macro returns the interrupt status read from Interrupt Status
* Register(IPISR). Use the XHI_IPIXR_* constants defined in xhwicap_l.h
* to interpret the returned value.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	The contents read from the Interrupt Status Register.
*
* @note		C-Style signature:
*		u32 XHwIcap_IntrGetStatus(InstancePtr)
*
******************************************************************************/
#define XHwIcap_IntrGetStatus(InstancePtr)				\
	XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, 	\
				XHI_IPISR_OFFSET)

/******************************************************************************/
/**
*
* This macro disables the specified interrupts in the Interrupt Enable
* Register. It is non-destructive in that the register is read and only the
* interrupts specified is changed.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
* @param	IntrMask is the bit-mask of the interrupts to be disabled.
*		Bit positions of 1 will be disabled. Bit positions of 0 will
*		keep the previous setting. This mask is formed by OR'ing
*		XHI_IPIXR_*_MASK bits defined in xhwicap_l.h.
*
* @return	None.
*
* @note		Signature:
*		void XHwIcap_IntrDisable(XHwIcap *InstancePtr, u32 IntrMask)
*
******************************************************************************/
#define XHwIcap_IntrDisable(InstancePtr, IntrMask)           \
XHwIcap_WriteReg((InstancePtr)->HwIcapConfig.BaseAddress, 	\
			XHI_IPIER_OFFSET, \
	XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, \
		XHI_IPIER_OFFSET) & (~ (IntrMask & XHI_IPIXR_ALL_MASK)));\
		(InstancePtr)->IsPolled = TRUE;

/******************************************************************************/
/**
*
* This macro enables the specified interrupts in the Interrupt Enable
* Register. It is non-destructive in that the register is read and only the
* interrupts specified is changed.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
* @param	IntrMask is the bit-mask of the interrupts to be enabled.
*		Bit positions of 1 will be enabled. Bit positions of 0 will
*		keep the previous setting. This mask is formed by OR'ing
*		XHI_IPIXR_*_MASK bits defined in xhwicap_l.h.
*
* @return	None.
*
* @note		Signature:
*		void XHwIcap_IntrEnable(XHwIcap *InstancePtr, u32 IntrMask)
*
******************************************************************************/
#define XHwIcap_IntrEnable(InstancePtr, IntrMask) \
	XHwIcap_WriteReg((InstancePtr)->HwIcapConfig.BaseAddress, 	\
			XHI_IPIER_OFFSET, \
	(XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, \
		XHI_IPIER_OFFSET) | ((IntrMask) & XHI_IPIXR_ALL_MASK))); \
		(InstancePtr)->IsPolled = FALSE;

/******************************************************************************/
/**
*
* This macro returns the interrupt status read from Interrupt Enable
* Register(IIER). Use the XHI_IPIXR_* constants defined in xhwicap_l.h
* to interpret the returned value.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	The contents read from the Interrupt Enable Register.
*
* @note		C-Style signature:
*		u32 XHwIcap_IntrGetEnabled(InstancePtr)
*
******************************************************************************/
#define XHwIcap_IntrGetEnabled(InstancePtr)				\
	XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, 	\
			XHI_IPIER_OFFSET)

/******************************************************************************/
/**
*
* This macro clears the specified interrupts in the Interrupt Status
* Register (IPISR).
*
* @param	InstancePtr is a pointer to the HwIcap instance.
* @param	IntrMask contains the interrupts to be cleared.
*
* @return	None.
*
* @note		Signature:
*		void XHwIcap_DisableIntr(XHwIcap *InstancePtr, u32 IntrMask)
*
******************************************************************************/
#define XHwIcap_IntrClear(InstancePtr, IntrMask)           \
	XHwIcap_WriteReg((InstancePtr)->HwIcapConfig.BaseAddress, 	\
			XHI_IPISR_OFFSET, \
		XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, \
		XHI_IPISR_OFFSET) | ((IntrMask) & XHI_IPIXR_ALL_MASK))

/******************************************************************************/
/**
*
* This macro returns the vacancy of the Write FIFO. This indicates the
* number of words that can be written to the Write FIFO before it becomes
* full.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	The contents read from the Write FIFO Vacancy Register.
*
* @note		C-Style signature:
*		u32 XHwIcap_GetWrFifoVacancy(InstancePtr)
*
******************************************************************************/
#define XHwIcap_GetWrFifoVacancy(InstancePtr)				\
 XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, XHI_WFV_OFFSET)

/******************************************************************************/
/**
*
* This macro returns the occupancy  of the Read FIFO.
*
* @param	InstancePtr is a pointer to the HwIcap instance.
*
* @return	The contents read from the Read FIFO Occupancy Register.
*
* @note		C-Style signature:
*		u32 XHwIcap_GetRdFifoOccupancy(InstancePtr)
*
******************************************************************************/
#define XHwIcap_GetRdFifoOccupancy(InstancePtr)		\
 XHwIcap_ReadReg((InstancePtr)->HwIcapConfig.BaseAddress, XHI_RFO_OFFSET)

#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* If Virtex4 device */

/****************************************************************************/
/**
*
* Converts a CLB SliceX coordinate to a column coordinate used by the
* XHwIcap_GetClbBits and XHwIcap_SetClbBits functions.
*
* @param	SliceX - the SliceX coordinate to be converted
*
* @return	Column
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceX2Col(u32 SliceX);
*
*****************************************************************************/
#define XHwIcap_SliceX2Col(SliceX) \
	( (SliceX >> 1) + 1)

/****************************************************************************/
/**
*
* Converts a CLB SliceY coordinate to a row coordinate used by the
* XHwIcap_GetClbBits and XHwIcap_SetClbBits functions.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	SliceY - the SliceY coordinate to be converted
* @return	Row
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceY2Row(XHwIcap *InstancePtr, u32 SliceY);
*
*****************************************************************************/
#define XHwIcap_SliceY2Row(InstancePtr, SliceY) \
	( (InstancePtr)->Rows - (SliceY >> 1) )

/****************************************************************************/
/**
*
* Figures out which slice in a CLB is targeted by a given
* (SliceX,SliceY) pair.  This slice value is used for indexing in
* resource arrays.
*
* @param	SliceX - the SliceX coordinate to be converted
* @param	SliceY - the SliceY coordinate to be converted
*
* @return	Slice index
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceXY2Slice(u32 SliceX, u32 SliceY);
*
*****************************************************************************/
#define XHwIcap_SliceXY2Slice(SliceX,SliceY) \
	( ((SliceX % 2) << 1) + (SliceY % 2) )

#elif ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
/****************************************************************************/
/**
*
* Converts a CLB SliceX coordinate to a column coordinate used by the
* XHwIcap_GetClbBits and XHwIcap_SetClbBits functions.
*
* @param	SliceX - the SliceX coordinate to be converted
*
* @return	Column
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceX2Col(u32 SliceX);
*
*****************************************************************************/
#define XHwIcap_SliceX2Col(SliceX) \
	( ((SliceX) >> 1) + 1)

/****************************************************************************/
/**
*
* Converts a CLB SliceY coordinate to a row coordinate used by the
* XHwIcap_GetClbBits and XHwIcap_SetClbBits functions.
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	SliceY - the SliceY coordinate to be converted
* @return	Row
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceY2Row(XHwIcap *InstancePtr, u32 SliceY);
*
*****************************************************************************/
#define XHwIcap_SliceY2Row(InstancePtr, SliceY) \
	((InstancePtr)->Rows - (SliceY))

/****************************************************************************/
/**
*
* Figures out which slice in a CLB is targeted by a given
* (SliceX,SliceY) pair.  This slice value is used for indexing in
* resource arrays.
*
* @param	SliceX - the SliceX coordinate to be converted
* @param	SliceY - the SliceY coordinate to be converted
*
* @return	Slice index
*
* @note		C-style Signature:
*		u32 XHwIcap_SliceXY2Slice(u32 SliceX, u32 SliceY);
*
*****************************************************************************/
#define XHwIcap_SliceXY2Slice(SliceX,SliceY) \
	((SliceX) % 2)

#endif
/************************** Function Prototypes *****************************/

/*
 * Functions in the xhwicap.c
 */
int XHwIcap_CfgInitialize(XHwIcap *InstancePtr, XHwIcap_Config *ConfigPtr,
				u32 EffectiveAddr);

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)
int XHwIcap_DeviceWrite(XHwIcap *InstancePtr, u16 *FrameBuffer, u32 NumWords);
int XHwIcap_DeviceRead(XHwIcap *InstancePtr, u16 *FrameBuffer, u32 NumWords);
#else
int XHwIcap_DeviceWrite(XHwIcap *InstancePtr, u32 *FrameBuffer, u32 NumWords);
int XHwIcap_DeviceRead(XHwIcap *InstancePtr, u32 *FrameBuffer, u32 NumWords);
#endif
void XHwIcap_Reset(XHwIcap *InstancePtr);
void XHwIcap_FlushFifo(XHwIcap *InstancePtr);
void XHwIcap_Abort(XHwIcap *InstancePtr);

/*
 * Functions in xhwicap_sinit.c.
 */
XHwIcap_Config *XHwIcap_LookupConfig(u16 DeviceId);

/*
 * Functions in the xhwicap_srp.c
 */
int XHwIcap_CommandDesync(XHwIcap *InstancePtr);
int XHwIcap_CommandCapture(XHwIcap *InstancePtr);
u32 XHwIcap_GetConfigReg(XHwIcap *InstancePtr, u32 ConfigReg, u32 *RegData);


/*
 *  Function in xhwicap_selftest.c
 */
 int XHwIcap_SelfTest(XHwIcap *InstancePtr);

/*
 *  Function in xhwicap_intr.c
 */
void XHwIcap_IntrHandler(void *InstancePtr);
void XHwIcap_SetInterruptHandler(XHwIcap * InstancePtr, void *CallBackRef,
			   XHwIcap_StatusHandler FuncPtr);

/*
 * Functions in the xhwicap_device_read_frame.c
 */
#if (XHI_FAMILY != XHI_DEV_FAMILY_S6)
int XHwIcap_DeviceReadFrame(XHwIcap *InstancePtr, long Top,
				long Block, long HClkRow,
				long MajorFrame, long MinorFrame,
				u32 *FrameBuffer);

/*
 * Functions in the xhwicap_device_write_frame.c
 */
int XHwIcap_DeviceWriteFrame(XHwIcap *InstancePtr, long Top,
				long Block, long HClkRow,
				long MajorFrame, long MinorFrame,
				u32 *FrameData);

#else
int XHwIcap_DeviceReadFrame(XHwIcap *InstancePtr, long Block, long Row,
				long MajorFrame, long MinorFrame,
				u16 *FrameBuffer);
/*
 * Functions in the xhwicap_device_write_frame.c
 */
int XHwIcap_DeviceWriteFrame(XHwIcap *InstancePtr, long Block, long Row,
				long MajorFrame, long MinorFrame,
				u16 *FrameData);

#endif

#if XHI_FAMILY == XHI_DEV_FAMILY_V4 /* If Virtex4 device */
#define XHwIcap_SetClbBits XHwIcap_SetClbBitsV4
#define XHwIcap_GetClbBits XHwIcap_GetClbBitsV4

#elif ((XHI_FAMILY == XHI_DEV_FAMILY_V5) || (XHI_FAMILY == XHI_DEV_FAMILY_V6))
		/* If Virtex5 or Virtex6 device */
#define XHwIcap_SetClbBits XHwIcap_SetClbBitsV5
#define XHwIcap_GetClbBits XHwIcap_GetClbBitsV5
#endif


/****************************************************************************/
/**
*
* Sets bits contained in a Center tile specified by the CLB row and col
* coordinates.  The coordinate system lables the upper left CLB as
* (1,1).
*
* @param	InstancePtr is a pointer to the XHwIcap instance to be worked on.
* @param	Row is the CLB row. (1,1) is the upper left CLB.
* @param	Col is the CLB col. (1,1) is the upper left CLB.
* @param	Resource is the Target bits (first dimension length will be
*		the number of bits to set and must match the numBits parameter)
*		(second dimension contains two value -- one for
*		 minor row and one for col information from within
*		the Center tile targetted by the above row and
*		col coords).
* @param	Value is the values to set each of the targets bits to.
*		The size of this array must be euqal to NumBits.
* @param	NumBits is the number of Bits to change in this method.
*
* @return	XST_SUCCESS, XST_BUFFER_TOO_SMALL or XST_INVALID_PARAM.
*
* @note		The source code for this function is not included. This function
*		is delivered as .o file. Libgen uses the appropriate .o file for the
*		target processor.
*
*****************************************************************************/
int XHwIcap_SetClbBits(XHwIcap *InstancePtr, long Row, long Col,
		const u8 Resource[][2], const u8 Value[], long NumBits);

/****************************************************************************/
/**
*
* Gets bits contained in a Center tile specified by the CLB row and col
* coordinates.  The coordinate system lables the upper left CLB as
* (1,1).
*
* @param	InstancePtr is a pointer to the XHwIcap instance.
* @param	Row is the CLB row. (1,1) is the upper left CLB.
* @param	Col is the CLB col. (1,1) is the upper left CLB.
* @param	Resource is the Target bits (first dimension length will be
*		the number of bits to set and must match the numBits parameter)
*		(second dimension contains two value -- one for
*		 minor row and one for col information from within
*		the Center tile targetted by the above row and
*		col coords).
* @param	Value is the values to set each of the targets bits to.
*		The size of this array must be euqal to NumBits.
* @param	NumBits is the number of Bits to change in this method.
*
* @return	XST_SUCCESS, XST_BUFFER_TOO_SMALL or XST_INVALID_PARAM.
*
* @note		The source code for this function is not included. This function
*		is delivered as .o file.  Libgen uses the appropriate .o file for the
*		target processor.
*
*****************************************************************************/
int XHwIcap_GetClbBits(XHwIcap *InstancePtr, long Row, long Col,
      const u8 Resource[][2], u8 Value[], long NumBits);


/************************** Variable Declarations ***************************/

#ifdef __cplusplus
}
#endif

#endif

