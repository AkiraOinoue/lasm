;asm_div(edi(Q), esi(M), rdx(Remd))
; ***** 失敗する。Aの扱いが不明 ********
;
; Q = Q / M
;全ビットの整数除算
;論理演算による除算関数
;$1:Q			edi(Dividend)
;$2:M			esi(Divisor)
;$3:余り		[rdx](Remainder)
;return		eax(Q)
global asm_div
section .data
section .bss
q_rst			resd	1
msb_cnt		resd	1 ; 被除数のMSBインデックス(32-1)
max_bit		resd	1 ; 被除数のMSBインデックス(31-0)
Q				resd	1 ; 被除数(Dividend)
M				resd	1 ; 除数(Divisor)
A				resd	1 ; 
;Set Register A = Dividend = 000000 :Aに0を代入
;Set Register Q = Dividend = 101110 :QにDividend(esi)を代入
;( So AQ = 000000 101110 , Q0 = LSB of Q = 0 )
;Set M = Divisor = 010111, M' = 2's complement of M = 101001 :lsubをコールするので不要
;Set Count = 6, since 6 digits operation is being done here.

section .text
asm_div:
	enter 	0,0
;Initialize
	;戻り値初期化
	xor eax,		eax
	mov	[q_rst],	eax
	;QのMSBビット+1を求めるｰ>msb_cntへ格納
	;1が見つかればZF=0,なければZF=1
	bsr	ebx,		edi
	jnz				L_Continue ; ZF=0
	mov eax,		0 ;戻り値=0
	mov [rdx],		eax ;余り=0
	leave
	ret
	
L_Continue:
	mov [max_bit], ebx
	inc	ebx
	mov [msb_cnt],	ebx
	;Aに0を代入
	xor eax,		eax
	mov [A],		eax
	;QにDividendを代入
	mov [Q],		edi
	;MにDivisorを代入
	mov [M],		esi

;Main Loop
Div_Loop:
;if A < 0
;{
;shift left A, Q and A = A + M
	mov eax,	[A]
	bt	eax,	31
	jnc			Else_01
	shl	eax	,	1	;shift left A
	mov [A],	eax

	mov eax,	[max_bit]
	btr [Q],	eax ; 最上位ビット=0
	mov eax,	[Q]
	shl eax,	1	;shift left Q
	mov [Q],	eax

	mov ebx,	[M]
	mov eax,	[A]
	add eax,	ebx	;A = A + M
	mov [A], 	eax
	jmp Out_Of_IF_Block01
;}
;else
;{
	;shift left A, Q and A = A - M
Else_01:
	mov eax,	[max_bit]
	btr [A],	eax ; 最上位ビット=0
	mov eax,	[A]
	shl eax,	1	;shift left A
	mov [A],	eax
	mov eax,	[max_bit]
	btr [Q],	eax ; 最上位ビット=0
	mov eax,	[Q]
	shl eax,	1	;shift left Q
	mov [Q],	eax

	mov ebx,	[M]
	mov eax,	[A]
	sub eax,	ebx ;A = A - M
	mov [A],	eax
;}
Out_Of_IF_Block01:
;if A < 0
;{
;Q:0 = 0
	mov eax,	[A]
	bt  eax,	31
	jnc 		Else_02
	mov eax,	[Q]
	btr eax,	0
	mov [Q],	eax ; Q:0 = 0
	jmp			Out_Of_IF_Block02
;}
Else_02:
;else
;{
;Q:0 = 1
	mov eax,	[Q]
	bts eax,	0
	mov [Q],	eax ; Q:0 = 1
;}
Out_Of_IF_Block02:
	;msb_cnt--;
	mov eax,		[msb_cnt]
	dec eax
	mov [msb_cnt],	eax
	;if msb_cnt == 0 then goto Ending
	jz 			Out_Of_Loop
	;else goto Div_Loop
	jmp			Div_Loop
	
Out_Of_Loop: ; Ending
	;if A < 0 then A = A + M
	mov eax,		[A]
	bt	eax,		31
	jnc  			L_Ret
	mov ebx,		[M]
	add eax,		ebx
	mov [A],		eax
	
L_Ret:
	mov eax,		[A]
	mov [rdx],		eax ;余りを設定
	mov eax,		[Q] ;除算結果
	leave
	ret
