;bit_add_h(edi, ebx(lh), edx(rh))
;ビット毎の加算
;ビット数				edi
;lhの指定ビットを検査	ebx
;rhの指定ビットを検査	edx
;return				eax
;CF = 1 or 0
section .data
t1	db	0
t2	db	0
section .text
bit_add_h:
	;bitlにビット数を設定
	mov eax,	edi	; ビット数
	mov cl,	al	;  bitl: 8ビットレジスターに代入
	
	;T t1 = ((this->m_lh >> bitl) & 1);
	mov eax,	ebx	; lh
	pushf			; carry退避
	shr	eax,	cl	;this->m_lh >> bitl
	and al,	1	; 
	mov [t1],	al	; t1 = al
	
	;T t1 = ((this->m_rh >> bitl) & 1);
	mov eax,	edx ; rh
	shr	eax,	cl ;this->m_lh >> bitl
	and al,	1	; 
	mov [t2],	al ; t2 = al
	
	;t1 and t2 -> carry (1 or 0)
	mov eax,	0
	mov al,	[t2]
	mov ebx,	0
	mov bl,	[t1]
	and al,	bl
; if (cl == 0) {
	cmp cl,	0
	jne CL_NonZero;
	;cl=0の処理。CF |= (t1&t2)
	popf		; carry復帰
	lahf		; AH <- CF
	or al,		ah
	bt ax,		0;	bit0の値をcarryに設定
	jmp CL_Next
;} else {
CL_NonZero:
	;cl!=0の処理。CF = (t1&t2)
	popf		; carry復帰
	bt ax,		0;	bit0の値をcarryに設定
;}
CL_Next:
	;t1 xor t2
	pushf		;carry退避
	mov eax,	0
	mov al,	[t1]
	mov ah,	[t2]
	xor al,	ah
	xor ah,	ah
	popf		;carry復帰
	ret

;bit_add(edi, ebx, edx)
;ビット毎の加算（キャリーフラグ付き）
;ビット数				edi
;lhの指定ビットを検査	ebx
;rhの指定ビットを検査	edx
;return				eax
section .data
section .bss
XF		resb	1 ;下位ビットからの桁上げ
BIT		resd	1
LH		resd	1
RH		resd	1
section .text
bit_add:
	pushf		;carryを退避
	cmp edi,	0
	jne	L_carry_add; edi != 0
	popf		;carryを復帰
	; 0ビット加算
	call bit_add_h;
	jmp	bit_add_Exit;
L_carry_add: ;bit > 0
	popf		;carryを復帰
	;carryの値を下位ビットからのフラグに設定
	mov eax,	0
	lahf		 ; EFLAGSをAHへ設定
	mov al,	ah
	pushf		;carryを退避
	and al,	1 ; LSBの値のみを取得
	mov [XF],	al; 下位加算結果のキャリーフラグを保存
	popf		;carryを復帰
	
	; 該当ビットを加算
	call bit_add_h
	
	;加算結果とキャリーフラグとの加算
	mov [BIT],	edi
	mov [LH],	ebx
	mov [RH],	edx

	mov ebx,	eax; lh<-加算結果をebxへ代入
	mov edx,	0
	mov dl,	[XF]; rh<-桁上げ値を代入
	mov edi,	0; ビット位置<-計算対象ビットを0に設定
	call bit_add_h; LSB同士を加算
	mov edi,	[BIT]
	mov ebx,	[LH]
	mov edx,	[RH]
bit_add_Exit:
	ret

;ladd(edi, esi(lh), edx(rh))
;全ビットの加算
;論理演算による加算関数
;$1:ビット数		edi
;$2:lh			esi
;$3:rh			edx
;return		eax
global ladd
section .data
section .bss
add_rst		resd	1
bit_cnt		resd	1
bitmax			resd	1
lh				resd	1
rh				resd	1
section .text
ladd:
	enter 	0,0
	;戻り値の初期化
	clc				;carryフラグクリア
	mov eax,		0
	mov [add_rst],	eax
	mov ecx,		0; ビットカウンタ初期化
	mov [bitmax],	edi
	mov ebx,		esi
	mov [lh],		ebx
	mov [rh],		edx
Loop.ladd:
	pushf		;carryを退避
	cmp ecx,		edi; ビットカウンタに到達したか
	je	Exit.Loop; ループ処理脱出
	popf		;carryを復帰

	mov [bit_cnt],	ecx
	;該当ビットを加算
	;bit_add(edi(bit), ebx(lh), edx(rh))
	mov edi,		ecx
	call bit_add;
	mov edx,		[rh]
	mov ebx,		[lh]
	mov edi, 		[bitmax]
	mov ecx,		[bit_cnt]
	
	pushf		;carryを退避
	shl eax,		cl; 加算結果のビットをシフト
	or [add_rst],	eax; 前回の加算結果にマージ
	inc ecx
	popf		;carryを復帰
	jmp	Loop.ladd
Exit.Loop:
	popf		;carryを復帰
	mov eax,		[add_rst]
	leave
	ret

;lsub(edi, esi(lh), edx(rh))
;全ビットの減算
;論理演算による減算関数
;$1:ビット数		edi
;$2:lh			esi
;$3:rh			edx
;return		eax
global lsub
section .text
lsub:
	enter 	0,0
	neg edx
	call ladd
	leave
	ret
