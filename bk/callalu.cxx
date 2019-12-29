#include <cstdio>
#include <iostream>
#include <x86_64-linux-gnu/asm/unistd_64.h>

//extern "C" int asmadd(int, int);
extern "C" int ladd(int bit, int lh, int rh);
extern "C" int lsub(int bit, int lh, int rh);
extern "C" int lmul(int bit, int lh, int rh);
extern "C" int asm_div(int lh, int rh, int* remn);
//extern "C" long long asmadd(long long, long long);

using namespace std;

int main(int agc, char** agv)
{
	int retv = 0;
	int remn = 0;
	int lh = 2;
	int rh = 3;
	if (agc > 1)
	{
		lh = atoi(agv[1]);
		rh = atoi(agv[2]);
	}
/*
	long long n1, n2;
	n1 = 1;
	n2 = 2;
	n2 = asmadd( n1, n2);
*/
	retv = asm_div(lh, rh, &remn);
	cout << lh << "/" << rh << "=" << retv << endl;
	cout << "remain=" << remn << endl;
	
	retv = lmul(32, lh, rh);
	cout << lh << "x" << rh << "=" << retv << endl;

	retv = ladd(32, lh, rh);
	cout << lh << "+" << rh << "=" << retv << endl;
	
	retv = lsub(32, lh, rh);
	cout << lh << "-" << rh << "=" << retv << endl;

	return retv;
}
