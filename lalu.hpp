//////////////////////////////
// 論理演算による計算クラス
//	2019/10/20
// arithmetic logic unit
//////////////////////////////
#include <map>
#include <string>
extern "C" unsigned long ladd(int bit, int lh, int rh);
extern "C" unsigned long lsub(int bit, int lh, int rh);
extern "C" unsigned long lmul(int bit, int lh, int rh);
extern "C" unsigned long l_div(int lh, int rh, int* remn);

namespace CPU
{
	enum  Operand
	{
		e_add = 0,
		e_sub,
		e_mul,
		e_ladd = 90,
		e_lsub,
		e_lmul,
		e_ldiv,		
	};

template <typename T>
class ALU
{
public:
	ALU(T lh, T rh)
	{
		this->m_lh = lh;
		this->m_rh = rh;
		this->cflg = 0;
		this->xflg = 0;
		this->m_bitw = 32;
	}
	ALU(int bitw = 32)
	{
		this->m_bitw = bitw;
		this->cflg = 0;
		this->xflg = 0;
	}
	Operand Map(char* ope)
	{
		return this->m_opemap[std::string(ope)];
	}
	void flgreset()
	{
		this->cflg = 0;
		this->xflg = 0;
	}
	// Assembler Logical Function
	// long ladd( int bit, int lh, int rh )
	long ladd( int lh, int rh )
	{
		return ::ladd( this->m_bitw, lh, rh );
	}	

	// Assembler Logical Function
	// long lsub( int bit, int lh, int rh )
	long lsub( int lh, int rh )
	{
		return ::lsub( this->m_bitw, lh, rh );
	}	

	// Assembler Logical Function
	// long lmul( int bit, int lh, int rh )
	long lmul( int lh, int rh )
	{
		return ::lmul( this->m_bitw, lh, rh );
	}	
	// Assembler Logical Function
	long ldiv( int lh, int rh )
	{
		return ::l_div( lh, rh, &(this->m_remn) );
	}

	// 左シフト
	// $1: 左シフトビット数
	// $2: データ
	T sla(int bitl, T lh)
	{
		return (lh << bitl);
	}
	// 2の補数を返す
	T neg(T lh)
	{
		return (~lh + 1);
	}
	// ビットテスト
	// $1: ビット位置(0-n)
	// $2: データ
	// return: 1 or 0
	int bit(int bitl, T lh)
	{
		return ((lh >> bitl) & 1);
	}
	// 乗算結果を返す
	// $1: 演算データ
	// $2: 演算データ
	// return: 乗算結果値	
	T mul(T lh, T rh)
	{
		T retv = 0;
		for ( int bit_ii = 0; bit_ii < this->m_bitw; bit_ii++)
		{
			// rhの1になっているビット位置をテスト
			if (1 == this->bit(bit_ii, rh))
			{
				retv = this->add(
					retv,
					this->sla(bit_ii, lh) // lhを左へbit_iiビットシフト
				);
			}
		}
		return retv;
	}
	// 減算結果を返す
	// $1: 演算データ
	// $2: 演算データ
	// return: 減算結果値	
	T sub(T lh, T rh)
	{
		this->m_lh = lh;
		this->m_rh = this->neg(rh); // 2の補数に変換
		return this->add();
	}		
	// 加算結果を返す
	// $1: 演算データ
	// $2: 演算データ
	// return: 加算結果値	
	T add(T lh, T rh)
	{
		this->m_lh = lh;
		this->m_rh = rh;
		return this->add();
	}
	// 加算結果を返す
	// 引数なし
	// return: 加算結果値	
	T add()
	{
		T add_rst = 0;
		for ( int ii = 0; ii < this->m_bitw; ii++ )
		{
			add_rst |= (this->bit_add(ii) << ii);
		}
		return add_rst;
	}
public:
	// 除算の余り
	int m_remn;
private:
	// データ
	T m_lh;
	T m_rh;
	unsigned char cflg; // 上位キャリーフラグ
	unsigned char xflg; // 下位キャリーフラグ
	int m_bitw; // データのビット幅
	// オペランドマップ
	std::map<std::string, Operand> m_opemap
	{
		{"add", Operand::e_add},
		{"sub", Operand::e_sub},
		{"mul", Operand::e_mul},
		{"ladd", Operand::e_ladd},
		{"lsub", Operand::e_lsub},
		{"lmul", Operand::e_lmul},
		{"ldiv", Operand::e_ldiv}
	};
private:
	// 指定ビット毎の加算結果を返す
	// $1: 演算ビット位置(0-n)
	// return: 加算結果ビット値
	// https://zariganitosh.hatenablog.jp/entry/20110818/how_do_cpu_calculate
	T bit_add(int bitl)
	{
		T add_rst;
		if (bitl == 0)
		{
			// 対象ビットの加算
			add_rst = this->bit_addh(bitl);
		}
		else
		{
			// 下位桁で発生したキャリーフラグを取得
			this->xflg = this->cflg;
			// 対象ビットの加算
			add_rst = this->bit_addh(bitl);
			// 加算結果とキャリーフラグとの加算
			add_rst = this->bit_addh(add_rst, this->xflg);
		}
		return add_rst;
	}

	// メソッド
	// 該当ビットの加算と上位へのキャリーフラグの設定
	T bit_addh(int bitl)
	{
		T t1 = ((this->m_lh >> bitl) & 1);
		T t2 = ((this->m_rh >> bitl) & 1);
		// 上位キャリーフラグ
		this->cflg = (t1 & t2);
		// 加算結果 XOR
		return (t1 ^ t2);
	}
	// 0ビットの加算と上位へのキャリーフラグの設定
	T bit_addh(T lh, T rh)
	{
		T t1 = (lh & 1);
		T t2 = (rh & 1);
		// 上位キャリーフラグ
		this->cflg |= (t1 & t2);
		// 加算結果 XOR
		return (t1 ^ t2);
	}
};
}
