//---------------------------------------------------------------------------
#ifndef cchronometherH
#define cchronometerH
//---------------------------------------------------------------------------
#include <xtmrctr_l.h>		//declaration of XTmrCtr functions

	class CChronometer
		{
		private:
			unsigned int BaseAddr;
			unsigned char Num;
		public:
			inline CChronometer(unsigned int xpar_timer_baseaddr,unsigned char timer_num) 
				{
				BaseAddr=xpar_timer_baseaddr;
				Num=timer_num;
				XTmrCtr_SetLoadReg(BaseAddr,Num,0);
				};
			inline void Start() 
				{
				XTmrCtr_SetControlStatusReg(BaseAddr,Num,XTC_CSR_LOAD_MASK);
				XTmrCtr_SetControlStatusReg(BaseAddr,Num,XTC_CSR_ENABLE_TMR_MASK);
				};
			inline void Restart()
				{
				XTmrCtr_SetControlStatusReg(BaseAddr,Num,XTC_CSR_ENABLE_TMR_MASK);
				}
			inline void Stop()
				{
				XTmrCtr_SetControlStatusReg(BaseAddr,Num,0);
				}
			inline unsigned int Read() 
				{
				return XTmrCtr_GetTimerCounterReg(BaseAddr,Num); 
				};
		};
//---------------------------------------------------------------------------
#endif
