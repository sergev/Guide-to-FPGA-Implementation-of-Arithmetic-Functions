#include <string.h>
#include <iostream>
#include <fstream>
#include "caes128.h"

//---------------------------------------------------------------------------
using namespace std;

CAES128 cipher;
char aes_mode,stream_mode,aes_bypass;
unsigned char aes_key[AES128_KEY_SIZE/8];
unsigned char aes_bin[AES128_BLOCK_SIZE/8],aes_bout[AES128_BLOCK_SIZE/8];

int console_getnibble(unsigned char *nibble,char digit)
{
if(digit>='0' && digit<='9')
	{*nibble=digit-'0';
	return 0;}
if(digit>='A' && digit<='F')
	{*nibble=10+digit-'A';
	return 0;}
if(digit>='a' && digit<='f')
	{*nibble=10+digit-'a';
	return 0;}
return -1;
}

int console_gethex(unsigned char *data,char hex[2])
{
unsigned char nibble0,nibble1;
if(console_getnibble(&nibble0,hex[0])!=0 || console_getnibble(&nibble1,hex[1])!=0)
	return -1;
*data=(nibble0<<4)|nibble1;
return 0;
}

int console_sethexkey(unsigned char key[],char hexkey[])
{
if(strlen(hexkey)!=2*AES128_KEY_SIZE/8)
	return -1;
for(int j=0; j<AES128_KEY_SIZE/8; j++)
	if(console_gethex(&key[j],&hexkey[2*j])!=0)
		return -1;
return 0;
}

int console_setstrkey(unsigned char key[],char strkey[])
{
if(strlen(strkey)!=AES128_KEY_SIZE/8)
	return -1;
for(int j=0; j<AES128_KEY_SIZE/8; j++)
	key[j]=(unsigned char)strkey[j];
return 0;
}

int console_setkey(unsigned char key[],char strkey[])
{
int status=-1;
if(strkey[0]=='0' && strkey[1]=='x')
	status=console_sethexkey(key,&strkey[2]);
else
	status=console_setstrkey(key,&strkey[0]);
if(status!=0)
	cerr<<"Invalid 128-bit KEY"<<endl;
return status;
}

int console_open_ifstream(ifstream &st,char fname[],char mode)
{
ios_base::openmode st_mode;
if(mode=='b')
	st_mode=ios_base::binary;
st.open(fname,st_mode);
if(st.fail())
	{cerr<<"Error opening "<<fname<<endl;
	return -1;}
return 0;
}

int console_open_ofstream(ofstream &st,char fname[],char mode)
{
ios_base::openmode st_mode;
if(mode=='b')
	st_mode=ios_base::binary;
st.open(fname,st_mode);
if(st.fail())
	{cerr<<"Error opening "<<fname<<endl;
	return -1;}
return 0;
}

void console_cipher(unsigned char *bin,unsigned char *bout)
{
switch(aes_bypass)
	{
	case 'n': 
		switch(aes_mode)
			{
			case 'e': cipher.Encrypt(bin,bout); break;
			case 'd': cipher.Decrypt(bin,bout); break;
			}
		break;
	case 'y': 
		for(int j=0; j<AES128_BLOCK_SIZE/8; bout[j]=bin[j], j++); 
		break;
	}
}

void console_aes128_getcon(istream &din,ostream &dout)
{
while(!din.eof())	
	{
	for(int j=0; j<AES128_BLOCK_SIZE/8; aes_bin[j++]=0x00);
	
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=din.get();
		aes_bin[j]=c;
		if(din.eof() || !c || c=='\n') break;}
	
	console_cipher(aes_bin,aes_bout);
	
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=aes_bout[j];
		dout.put(c);}
	}
}

void console_aes128_putcon(istream &din,ostream &dout)
{
while(!din.eof())	
	{
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=din.get();
		aes_bin[j]=c;
		if(din.eof()) break;}
	
	console_cipher(aes_bin,aes_bout);
	
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=aes_bout[j];
		if(!c) break;
		dout.put(c);}
	}
}

void console_aes128_con(istream &din,ostream &dout)
{
switch(aes_mode)
	{
	case 'e': console_aes128_getcon(din,dout); break;
	case 'd': console_aes128_putcon(din,dout); break;
	}
}

void console_aes128_raw(istream &din,ostream &dout)
{
while(!din.eof())	
	{
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=din.get();
		aes_bin[j]=c;}
	
	console_cipher(aes_bin,aes_bout);
	
	for(int j=0; j<AES128_BLOCK_SIZE/8; j++)
		{char c=aes_bout[j];
		dout.put(c);}
	}
}

void console_aes128(istream &din,ostream &dout)
{
switch(stream_mode)
	{
	case 'r': console_aes128_raw(din,dout); break;
	case 'c': console_aes128_con(din,dout); break;
	}
}

int console_main(int argc, char* argv[])
{
int cnt_key=0,cnt_nokey=0,cnt_mode=0,cnt_unknow=0,cnt_fin=0,cnt_fout=0,cnt_stream_mode=0;
int idx_fin=0,idx_fout=0;
ifstream fin;
ofstream fout;

for(int j=1; j<argc; j++)
	{
	if(strcmp(argv[j],"-e")==0)
		{aes_mode='e';
		cnt_mode++;
		continue;}
	if(strcmp(argv[j],"-d")==0)
		{aes_mode='d';
		cnt_mode++;
		continue;}

	if(strcmp(argv[j],"-f")==0)
		{stream_mode='r';
		cnt_stream_mode++;
		continue;}
	if(strcmp(argv[j],"-c")==0)
		{stream_mode='c';
		cnt_stream_mode++;
		continue;}

	if(strcmp(argv[j],"-nk")==0)
		{j++;
		cnt_nokey++;
		continue;}
	if(strcmp(argv[j],"-k")==0)
		{j++;
		if(j<argc && console_setkey(aes_key,argv[j])==0)
			cnt_key++;
		continue;}

	if(strcmp(argv[j],"-if")==0)
		{j++; cnt_fin++;
		idx_fin=(j<argc)? j:-1;
		continue;}
	if(strcmp(argv[j],"-of")==0)
		{j++; cnt_fout++;
		idx_fout=(j<argc)? j:-1;
		continue;}
	cerr<<"Unknow parameter: "<<argv[j]<<endl;
	cnt_unknow++;
	}

if( cnt_key+cnt_nokey!=1 || cnt_mode!=1 || cnt_unknow!=0 || cnt_fin>=2 || idx_fin==-1 || cnt_fout>=2 || idx_fout==-1 || cnt_stream_mode!=1)
	{
	cerr<<"Encripts/Decripts an input stream using the AES 128-bit cipher/decipher\n";
	cerr<<"\nUsage:\n";
	cerr<<"  aes128 [-e|-d] [-c|-r] [-k KEY|-nk] [-if inputfile] [-of outputfile]\n";
	cerr<<"     -e => encripts\n     -d => decripts\n";
	cerr<<"     -k KEY => the 128-bit KEY, as an hexadecimal or as a string\n";
	cerr<<"       KEY example as an hexadecimal 0x...(32 hex digits)... => 0x000102030405060708090a0b0c0d0e0f\n";
	cerr<<"       KEY example as a string \"...(16 characters)...\" => \"SeCrEt KeY* 128\"\n";
	cerr<<"     -nk => no KEY, bypass the encriptation/decriptation (only for testing purposes)\n";
	cerr<<"     -r => raw stream, encripts/decripts the output/input stream without processing (usefull for file streams)\n";
	cerr<<"     -c => console stream, encripts/decripts the output/input stream processing the 'carriage-return' and 'end-of-string' characters (usefull for console streams)\n";
	cerr<<"     -if inputfile  => the input file to be encripted/decripted. If it's not provided, it uses the standard input\n";
	cerr<<"     -of outputfile => the output encripted/decripted file . If it's not provided, it uses the standard output\n";
	cerr<<"\nExamples:\n";
	cerr<<"  aes128 -e -r -k 0x120408a0b4ff347de246617620fba712 -if plain.txt -of cipher.txt\n";
	cerr<<"     => encripts the input file (plain.txt) to the output file (cipher.txt)\n";
	cerr<<"  aes128 -d -r -k \"A 128-bits*KEY!@\" < plain.txt >cipher.txt\n";
	cerr<<"     => decripts the redirected input (file plain.txt) to the redirected output (file cipher.txt)\n";
	cerr<<"  aes128 -d -c -k \"A 128-bits*KEY!@\" \n";
	cerr<<"     => decripts the standart input (console) to the standart output (console)\n";


	return -1;
}

bool ferror=false;
if(cnt_fin==1 && idx_fin!=-1)
	{char mode=(aes_mode=='e')? 't':'b';
	ferror|=console_open_ifstream(fin,argv[idx_fin],mode);}

if(cnt_fout==1 && idx_fout!=-1)
	{char mode=(aes_mode=='d')? 't':'b';
	ferror|=console_open_ofstream(fout,argv[idx_fout],mode);}

if(ferror)
	return -1;

if(cnt_key==1)
	{cipher.SetKey(aes_key);
	aes_bypass='n';}
if(cnt_nokey==1)
	aes_bypass='y';
	
switch(cnt_fin*2+cnt_fout)
	{
	case 0: console_aes128(cin,cout); break;
	case 1: console_aes128(cin,fout); break;
	case 2: console_aes128(fin,cout); break;
	case 3: console_aes128(fin,fout); break;
	}
return 0;
}


