/******************************************************************************
*
* (c) Copyright 2009 Xilinx, Inc. All rights reserved.
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
* @file xil_cache.h
*
* This header file contains cache related driver functions (or
* macros) that can be used to access the device.  The user should refer to the
* hardware device specification for more details of the device operation.
* The functions in this header file can be used across all Xilinx supported
* processors. For CPU specific cache related API, please use xil_mach_cache.h.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00  hbm  07/28/09 Initial release
*
* </pre>
*
* @note
*
* None.
*
******************************************************************************/

#ifndef XIL_CACHE_H
#define XIL_CACHE_H

#if defined XENV_VXWORKS
/* VxWorks environment */
#error "Unknown processor / architecture. Must be PPC for VxWorks."
#else
/* standalone environment */

#include "mb_interface.h"
#include "xil_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/****************************************************************************/
/**
*
* Invalidate the entire data cache. If the cacheline is modified (dirty),
* the modified contents are lost.
*
* @param    None.
*    
* @return   None.
*
* @note     
*
* Processor must be in real mode.
****************************************************************************/
#define Xil_DCacheInvalidate() microblaze_invalidate_dcache()


/****************************************************************************/
/**
*
* Invalidate the data cache for the given address range.
* If the bytes specified by the address (Addr) are cached by the data cache, 
* the cacheline containing that byte is invalidated.  If the cacheline 
* is modified (dirty), the modified contents are lost.
*
* @param    Addr is address of ragne to be invalidated.
* @param    Len is the length in bytes to be invalidated.
*    
* @return   None.
*
* @note     
*
* Processor must be in real mode.
****************************************************************************/
#define Xil_DCacheInvalidateRange(Addr, Len) \
        microblaze_invalidate_dcache_range(Addr, Len)

/****************************************************************************/
/**
* Flush the data cache for the given address range.
* If the bytes specified by the address (Addr) are cached by the data cache, 
* and is modified (dirty), the cacheline will be written to system memory.
* The cacheline will also be invalidated.
*
* @param    Addr is the starting address of the range to be flushed.
* @param    Len is the length in byte to be flushed.
*    
* @return   None.
*
****************************************************************************/
#define Xil_DCacheFlushRange(Addr, Len) \
        microblaze_flush_dcache_range(Addr, Len)

/****************************************************************************/
/**
* Flush the entire data cache. If any cacheline is dirty, the cacheline will be
* written to system memory. The entire data cache will be invalidated.
*
* @return   None.
*
* @note     
*
****************************************************************************/
#define Xil_DCacheFlush() microblaze_flush_dcache()

/****************************************************************************/
/**
*
* Invalidate the instruction cache for the given address range.
*
* @param    Addr is address of ragne to be invalidated.
* @param    Len is the length in bytes to be invalidated.
*    
* @return   None.
*
****************************************************************************/
#define Xil_ICacheInvalidateRange(Addr, Len) \
        microblaze_invalidate_icache_range(Addr, Len)

/****************************************************************************/
/**
*
* Invalidate the entire instruction cache.
*
* @param    None
*
* @return   None.
*
****************************************************************************/
#define Xil_ICacheInvalidate() \
        microblaze_invalidate_icache()


/****************************************************************************/
/**
*
* Enable the data cache.
*
* @return   None.
*
* @note     This is processor specific.
*
****************************************************************************/
#define Xil_DCacheEnable() \
        microblaze_enable_dcache()

/****************************************************************************/
/**
*
* Enable the instruction cache.
*
* @return   None.
*
* @note     This is processor specific.
*
****************************************************************************/
#define Xil_ICacheEnable() \
        microblaze_enable_icache()

extern void Xil_DCacheDisable(void);
extern void Xil_ICacheDisable(void);

#ifdef __cplusplus
}
#endif

#endif

#endif
