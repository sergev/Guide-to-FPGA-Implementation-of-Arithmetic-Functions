#define INPUT_NCHARS (10)

#include <xuartlite_l.h>	//declaration of XUartLite_RecvByte() function
#include <xparameters.h>	//declaration of XPAR_INSTANCE_BASEADDR's
#include "caes128.h"			//declaration of the Class CAES128

CAES128 Cipher;
bool quit=false;
/***************************************************************/
void decrypt(char *msg, char *string)
{
unsigned char block[AES128_BLOCK_SIZE/8];
unsigned int k=0;
char c=0xFF;

do
	{
	for(unsigned char j=0; j<AES128_BLOCK_SIZE/8; j++)
		block[j]=*msg++;

	Cipher.Decrypt(block,block);	
	
	for(unsigned char j=0; j<AES128_BLOCK_SIZE/8; j++)
		{if(c) c=block[j];
		string[k++]=c;}
		
	} while(c);
}
/***************************************************************/
void encrypt(char *string,char *msg)
{
unsigned char block[AES128_BLOCK_SIZE/8];
unsigned int k=0;
char c=0xFF;

do
	{
	for(unsigned char j=0; j<AES128_BLOCK_SIZE/8; j++)
		{if(c) c=string[k++];
		block[j]=c;}

	Cipher.Encrypt(block,block);
	
	for(unsigned char j=0; j<AES128_BLOCK_SIZE/8; j++)
		*msg++=block[j];
	
	} while(c);
}
/***************************************************************/
void send_rs232(char *txt)
{
unsigned int j=0;
char c;
while(c=txt[j++])
		XUartLite_SendByte(XPAR_RS232_BASEADDR,c);
}
/***************************************************************/
int main()
{
unsigned char key[AES128_KEY_SIZE/8]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
char plaintxt1[16*6]="#XXX\tThis is a test of encrypting for profiling\n\t\tIt uses the CAES128 Class!!!\n";
char ciphertxt[16*6];
char plaintxt2[16*6];

//send_rs232("START\n");
Cipher.SetKey(key);

unsigned int j=0;
char j1='0',j2='0',j3='0'; 
do
	{
	plaintxt1[1]=j1;
	plaintxt1[2]=j2;
	plaintxt1[3]=j3;
	encrypt(plaintxt1,ciphertxt);
	decrypt(ciphertxt,plaintxt2);
	//send_rs232(plaintxt2);
	if(j3++=='9')
		{j3='0';
		if(j2++=='9')
			{j2='0';
			if(j1++=='9')
				j1='0';
			}
		}
			
	} while(++j<100);
	
//send_rs232("END\n");
return 0;
}
