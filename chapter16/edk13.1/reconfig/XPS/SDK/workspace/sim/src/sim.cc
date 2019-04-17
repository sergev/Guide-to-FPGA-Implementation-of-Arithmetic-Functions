#include <fsl_rcopro.h>		//Driver header of the reconfigurable coprocessor
#include <xparameters.h>	//Declaration XPAR_DECOUPLER_GPIO_BASEADDR
/***************************************************************/
void reset_rcopro(bool assert)
{
*(volatile unsigned int *)(XPAR_DECOUPLING_GPIO_BASEADDR)=(assert)? 0x1:0x0;
}
/**********************************************/
int main()
{
int a[3][3]={{1,3,5},{-1,-2,-3},{2,4,0}};
int b[3][3]={{1,0,0},{0,1,0},{0,0,1}};
int o[3][3];
int d1,d2;

reset_rcopro(true);
reset_rcopro(false);
//fsl_rcopro_adder(a,b,o); fsl_rcopro_adder(o,b,o);
//fsl_rcopro_multiplier(a,b,o); fsl_rcopro_multiplier(o,b,o);
//fsl_rcopro_scalar_multiplier(2,a,o); fsl_rcopro_scalar_multiplier(-2,o,o); fsl_rcopro_scalar_multiplier(-10,b,o);
d1=fsl_rcopro_determinant(a); d2=fsl_rcopro_determinant(b);
}


