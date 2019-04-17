#ifndef BITSTREAM_H
	
	#define BITSTREAM_H

	class CBitStream
		{
		private:
			unsigned char *Addr;
			unsigned int Size;
			unsigned char *Header,*Ncdfile,*Fpga,*Date,*Time;
			inline void Hwicap_InitWrite();
			inline bool Hwicap_WordWrite(unsigned int word);

		public: 
			CBitStream();
			void ReadHeader(unsigned char *header);
			void PrintHeader();
			bool Reconfig();
		};
	
#endif 
