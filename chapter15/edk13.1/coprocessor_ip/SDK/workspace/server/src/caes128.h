//---------------------------------------------------------------------------
#ifndef caes128H
#define caes128H
//---------------------------------------------------------------------------
#define ENABLE_COPROCESSOR_MIXCOLUMNS	//Comment to dissable coprocessor acceleration

#define AES128_KEY_SIZE (128)
#define AES128_EXPKEY_SIZE (128*11)
#define AES128_BLOCK_SIZE (128)

	class CAES128
		{
		private:
			unsigned char State[4][4];
			unsigned char ExpKey[176];
			unsigned char Multiply(unsigned char,unsigned char);
			void WriteState(unsigned char[AES128_BLOCK_SIZE/8]);
			void ReadState(unsigned char[AES128_BLOCK_SIZE/8]);
			void ShiftRow(unsigned char [4],unsigned char);
			void AddExpKey(unsigned char);
			void SubBytes();
			void InvSubBytes();
			void ShiftRows();
			void InvShiftRows();
			unsigned char X(unsigned char);
			void MixColumns();
			void InvMixColumns();
		public:
			void SetKey(unsigned char key[AES128_KEY_SIZE/8]);
			void Encrypt(unsigned char in[AES128_BLOCK_SIZE/8], unsigned char out[AES128_BLOCK_SIZE/8]);
			void Decrypt(unsigned char in[AES128_BLOCK_SIZE/8], unsigned char out[AES128_BLOCK_SIZE/8]);
		};

//---------------------------------------------------------------------------
#endif
