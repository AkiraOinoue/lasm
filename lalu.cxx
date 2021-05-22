/*
 * main.cxx
 * 
 * Copyright 2019 Akira Oinoue <oinoue@oinoue-dynabook-T552-36FR>
 *
 * main.cxx
 * 
 * Copyright 2019 Akira Oinoue <oinoue@oinoue-dynabook-T552-36FR>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */
#include <string>
#include <iostream>
#include <exception>
#include "lalu.hpp"
using namespace std;

int main(int argc, char **argv)
{
	long  lh = 456;
	long  rh = 228;
	string mode="";
	
	try
	{
		if (argc == 2)
		{
			mode="debug: ";
			//lh = 0b0001100101101010; // 0x196A =   6506
			//rh = 0b0001101100101100; // 0x1B2C = + 6956
									//                 13462
			lh = 0x4000196A; // 1073748330
			rh = 0x40001B2C; // 1073748780
							   // 2147497110
		}
		else if (argc > 2)
		{
			lh = stoul(string(argv[2]));
			rh = stoul(string(argv[3]));
		}
		CPU::ALU<long> alu(32);
		long retv;
		if (argc > 2 )
		{
			cout << "function " << argv[1] << ": " << flush;
		}
		else
		{
			cout << "usage: lalu {命令} 第一オペランド　第二オペランド" << endl;
			cout << "{命令}: ladd lsub lmul ldiv add sub mul div" << endl;
			cout << "オペランドは10進数(DECIMAL)" << endl;
			cout << "例）乗算の場合：lalu lmul 5 3" << endl;
			cout << "結果：function lmul: 5*3=15" << endl;
			return 0;
		}

		int tmplh;
		int tmprh;
		switch(alu.Map(argv[1]))
		{
		case CPU::Operand::e_ladd:
			tmplh = lh;
			retv = alu.ladd(lh, rh);
			cout << mode << tmplh << "+" << rh << "=" << retv << endl;
			break;
		case CPU::Operand::e_lsub:
			tmplh = lh;
			retv = alu.lsub(lh, rh);
			cout << mode << tmplh << "-" << rh << "=" << retv << endl;
			break;
		case CPU::Operand::e_lmul:
			tmplh = lh;
			tmprh = rh;
			retv = alu.lmul(lh, rh);
			cout << mode << tmplh << "*" << tmprh << "=" << retv << endl;
			break;
		case CPU::Operand::e_ldiv:
			tmplh = lh;
			retv = alu.ldiv( lh, rh);
			cout << mode << tmplh << "/" << rh << "=" << retv << endl;
			cout << "remain=" << alu.m_remn << endl;
			break;
		case CPU::Operand::e_add:
			retv = alu.add(lh, rh);
			cout << mode << lh << "+" << rh << "=" << retv << endl;
			break;
		case CPU::Operand::e_sub:
			retv = alu.sub(lh, rh);
			cout << mode << lh << "-" << rh << "=" << retv << endl;
			break;
		case CPU::Operand::e_mul:
			retv = alu.mul(lh, rh);
			cout << mode << lh << "*" << rh << "=" << retv << endl;
			break;
		case CPU::Operand::e_div:
			retv = alu.div(lh, rh);
			cout << mode << lh << "/" << rh << "=" << retv << endl;
			cout << "remain=" << alu.m_remn << endl;
			break;
		default:
			cout << "対応する命令がありません。" << endl;
			break;
		} 
	}
	catch ( exception &ex )
	{
		cout << "error: " << ex.what() << endl;
	}
	return 0;
}
