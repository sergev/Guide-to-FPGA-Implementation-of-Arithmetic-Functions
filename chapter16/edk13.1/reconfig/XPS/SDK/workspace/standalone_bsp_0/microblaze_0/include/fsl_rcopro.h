#ifndef FSL_RCOPRO_H
#define FSL_RCOPRO_H

	#ifdef __cplusplus
	extern "C" {
	#endif
				
		void fsl_rcopro_dummy(int o[3][3]);
		void fsl_rcopro_adder(int a[3][3], int b[3][3], int o[3][3]);
		void fsl_rcopro_multiplier(int a[3][3], int b[3][3], int o[3][3]);
		void fsl_rcopro_scalar_multiplier(int k, int a[3][3], int o[3][3]);
		int fsl_rcopro_determinant(int a[3][3]);
		
	#ifdef __cplusplus
	}
	#endif

#endif 
