# プログラム名とオブジェクトファイル名
PROGRAM = lalu
OBJS = lalu.o asm_div.obj asm_mul.obj asm_alu.obj
# for Debug callalu.o
#OBJS = callalu.o asm_alu.obj asm_div.obj asm_mul.obj

#インクルードファイルパス
INCPATH = /usr/include/c++/9

# 定義済みマクロの再定義
CXXFLAGS = -fPIC -g -m64 -Wall -O2 -std=c++2a -I$(INCPATH)
LDFLAGS = -lstdc++ -lstdc++fs -no-pie
NASMFLAGS = -g -f elf64

# サフィックスルール適用対象の拡張子の定義
.SUFFIXES: .cxx .o

# リメイクルール
.PHONY: rebuild
rebuild:
	-@ echo ReMaking ...
	-@ make -silent clean
	-@ make -silent all

.PHONY: all
all:$(PROGRAM)

# プライマリターゲット
$(PROGRAM): $(OBJS)
	$(CXX) -o $(PROGRAM) $^ $(LDFLAGS)
	-@ echo Comleted ... $(PROGRAM)

#Assembler
%.obj: %.asm
	-@ echo Assembling ... $<
	nasm $(NASMFLAGS) $< -o $@

# サフィックスルール
.cxx.o:
	-@ echo Compiling ... $<
	$(CXX) $(CXXFLAGS) -c $<

# ファイル削除用ターゲット
.PHONY: clean
clean:
	-@ echo Cleaning ...
	-@ $(RM) -f $(PROGRAM) $(OBJS)

#デバッグ起動
.PHONY: debug
debug:
	gdb --command=gdbcmd --args lalu ladd 1  1

# ヘッダファイルの依存関係
.PHONY: depend
depend: $(OBJS:.o=.cxx)
	-@ $(RM) depend.inc
	-@ for i in $^; do cpp -MM $$i | sed "s/\ [_a-zA-Z0-9][_a-zA-Z0-9]*\.cxx//g" >> depend.inc; done

-include depend.inc
