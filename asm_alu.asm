;half_adder(bl(lh), dl(rh))
;ビット毎の加算
;lhのビット0	bl
;rhのビット0	dl
;return		Sum=al, CF=ah
;CF = 1 or 0
section .data
_BL db 0
_DL db 0
_AL db 0
_R2 db 0
_R3 db 0
section .text
half_adder:
	mov [_BL],	bl
	mov [_DL],	dl
	; bl+dl
	call NAND ; 1:retv = al
	mov [_AL],	al

	; bl+al
	mov bl,	[_BL]
	mov dl, al
	call NAND ; 2
	mov [_R2], al

	mov bl,	[_AL]
	mov dl,	[_DL]
	call NAND ; 3
	mov [_R3], al

	mov bl,	[_R2]
	mov dl,	[_R3]
	call NAND ; 4
	; CF
	mov ah,	[_AL]
	xor ah,	1
	ret

;NAND(bl(lh), dl(rh))
;ビット毎のNAND(AND NOT)
;lhのビット0	bl
;rhのビット0	dl
;return		NAND=al
section .text
NAND:
	mov al,	bl
	and al,	dl
	xor al,	1
	ret

;bit_add( bl, dl, CF )
; bl(lh:bit) + dl(rh:bit) + CF(ah:bit0)
; retv=sum(al:bit0), carry=(ah:bit0)
section .data
_CF0 db 0 ; 下位からのキャリーフラグ
_CF1 db 0 ; １回目加算のキャリーフラグ
section .text
bit_add:
	;half_adder(bl(lh), dl(rh))
	;ビット毎の加算
	;lhのビット0	bl
	;rhのビット0	dl
	;return		Sum=al, CF=ah
	mov [_CF0],	ah ; 下位からのキャリーフラグを取得
	call half_adder  ; bl + dl, ret=ah(CF)
	mov [_CF1],	ah
	mov bl,		al ; １回目の半加算結果と
	mov dl,	[_CF0] ; 下位からのキャリーフラグを加算
	call half_adder  ; bl + dl, ret=ah(CF)
	or ah,		[_CF1] ; １回目と２回目のキャリーのマージ
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
_CF		db	0
section .bss
add_rst		resd	1
bitmax			resd	1
lh				resd	1
rh				resd	1
section .text
ladd:
	enter 	0,0
; 初期化
	mov eax,		0
	mov [add_rst],	eax ;戻り値の初期化
	mov ecx,		0; ビットカウンタ初期化
	mov [bitmax],	edi
	mov ebx,		esi
	mov [lh],		ebx
	mov [rh],		edx
	mov [_CF],		ah	;carry flag = 0
	
Loop.ladd:
	cmp ecx,	[bitmax]; ビットカウンタに到達したか
	je	Exit.Loop; ループ処理脱出

	;該当ビットを加算
	;bit_add( bl(lh:bit) + dl(rh:bit) + CF(ah:bit0) )
	; retv=sum(al:bit0), carry=(ah:bit0)
	mov ebx,		[lh] ; lhを取得
	mov edx,		[rh] ; rhを取得
	shr ebx,		cl ; lhの対象ビットをシフト
	and bl,		1 ; bit0のみを取得
	shr edx,		cl ; rhの対象ビットをシフト
	and dl,		1 ; bit0のみを取得
	mov ah,		[_CF] ; 下位からのキャリーフラグを取得
	call bit_add	   ;キャリーフラグ付きビット加算
	mov [_CF],		ah ; キャリーフラグを保存
	xor ah,		ah ; ahレジスタークリア
	
	shl eax,		cl ; 加算結果のビットを左シフト
	or [add_rst],	eax; 前回の加算結果にマージ
	
	inc ecx			; カウントアップ
	jmp	Loop.ladd		; ループの先頭へジャンプ
Exit.Loop:
	mov eax,[add_rst] ; 加算結果を返す
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
section .data
lsub._CF		db	0
section .text
lsub:
	enter 	0,0
	cmp esi,	edx	;キャリーフラグ設定
	lahf			;フラグレジスタ→AH
	mov [lsub._CF],	ah
	
	neg edx
	call ladd

	push	rax		;演算結果退避
	mov ah,		[lsub._CF]
	sahf			;AH→フラグレジスタ
	pop		rax		;演算結果戻し
	leave
	ret
