#ifndef FSL_MIXCOLUMNS_AES128_H
#define FSL_MIXCOLUMNS_AES128_H

	#ifdef __cplusplus
	extern "C" {
	#endif
		#define MIXCOLUMNS (0)
		#define INVMIXCOLUMNS (1)
		 
		void fsl_mixcolumns(unsigned char mode,unsigned char state[4][4]);
	
	#ifdef __cplusplus
	}
	#endif

#endif 
