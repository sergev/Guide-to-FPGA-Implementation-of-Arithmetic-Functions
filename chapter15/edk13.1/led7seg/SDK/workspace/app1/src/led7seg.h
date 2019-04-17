#ifndef LED7SEG_H_
#define LED7SEG_H_

#define LED7SEG_SEGMENTS_ACTIVE_LOW (true)
#define LED7SEG_ANODES_ACTIVE_LOW (true)
#define LED7SEG_OFF 0x2		//Display OFF
#define LED7SEG_ZEROS 0x1	//Display left-side zeros

class CLed7Seg
	{
	private:
		void GPIO(unsigned char anodes,unsigned char segments);
		char Decode(char d);
		void Digit(char off,char zeros,short data,char idx);
		volatile int* GPIO_Data;
	public:
		CLed7Seg(int gpio_baseaddr);
		void Refresh();
		char Config;
		short Data;
	};

#endif
