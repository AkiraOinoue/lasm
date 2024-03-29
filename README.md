# 概要</br>
このコンテンツ（lasm=Logical Assembler）は、CPUの算術四則演算（符号なし整数の加減乗除）を論理演算(and,or,xor,ビットシフト命令など)によってソフトウェアでシミュレートしたアセンブリーソースコードです。ターゲットとしたCPUはIntel x86系（32ビット）です。</br>
# ソース</br>
C++:lalu.cxx  lalu.hpp</br>
Assembler:asm_alu.asm  asm_div.asm  asm_mul.asm</br>
make: makefile</br>
</br>
# 各演算のコーリングシーケンス</br>
C++のプログラムからの呼び出し方法を示します。</br>
＜加算処理（＋）＞</br>
 unsigned n = ladd(32, 100, 60);</br>
 引数１：データのビット幅（32固定）</br>
 引数２：オペランド１</br>
 引数３：オペランド２</br>
 結果：n = 160</br>
＜減算処理（－）＞</br>
 unsigned n = lsub(32, 100, 60);</br>
 引数１：データのビット幅（32固定）</br>
 引数２：オペランド１</br>
 引数３：オペランド２</br>
 結果：n = 40</br> 
＜乗算処理（×）＞</br>
 unsigned n = lmul(32, 100, 60);</br>
 引数１：データのビット幅（32固定）</br>
 引数２：オペランド１</br>
 引数３：オペランド２</br>
 結果：n = 6000</br> 
＜除算処理（÷）＞</br>
 unsigned n = l_div(100, 60, &rem);</br>
 引数１：オペランド１</br>
 引数２：オペランド２</br>
 引数３：余り（整数型ポインタ）</br>
 結果：n = 1、rem = 40</br>
</br>
※）各演算結果がオーバーフローやマイナスになると想定外の値が返ります。</br>
</br>
# テストプログラム</br>
　lasmの動作確認用のC++コンソールプログラム（lalu.cxx）です。各演算は起動引数で指定します。</br>
＜起動方法＞</br>
usage: lalu {命令}　第一オペランド　第二オペランド</br>
{命令}：ladd,lsub,lmul,ldiv</br>
例）乗算命令の場合：lalu lmul 100 60</br>
結果：function lmul: 100*60=6000</br>
</br>
# 開発環境</br>
＜OS＞</br>
  Linux(Ubuntu 18.04.1)</br>
＜開発ツール＞</br>
開発統合ツール：Geany ver1.36</br>
アセンブラ：nasm ver2.14.02</br>
C++コンパイラ：gcc 10.2.0以上</br>
