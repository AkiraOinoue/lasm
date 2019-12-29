;l_div(edi(Q), esi(M), rdx(Remd))
;Created  2019/11/24
;*******************************************
;Functions
;*******************************************
section .data
section .bss
q_rst			resd	1
shf_cnt		resd	1 ; シフトカウンター
Q				resd	1 ; 被除数(Dividend)
M				resd	1 ; 除数(Divisor)
tmp				resd	1 ; テンポラリー変数

section .text
F_InitialCheck:
	; 初期チェク
	; ZF = 1 なら処理中断
	xor eax,	eax
	mov [tmp],	eax
	or  [tmp], edi
	jz			L_NG ; if edi == 0 then ZF = 1
	mov [tmp], eax
	or  [tmp],	esi ; if esi == 0 then ZF = 1
L_NG:
	ret

F_GetMSBCount:
	; M (Divisor)のMSBを求めて左シフトして最大値にする（符号なし）
	; QにDividendを格納
	; シフトカウンター格納
	bsr ebx,		esi
	mov eax,		31
	sub eax,		ebx
	mov [shf_cnt],	eax
	mov ecx,		eax
	
	; Mを左シフト
	mov eax,		esi
	shl eax,		cl
	mov [M],		eax	

	; Q(Dividend)を格納
	mov [Q],		edi
	ret

F_RsltInit:
	; 結果バッファをクリア
	; 余りバッファをクリア
	xor eax,		eax
	mov [q_rst],	eax ; 除算結果
	mov [rdx],		eax ; 余り
	mov [Q],		edi ; 被除算数
	ret

F_ShiftSetRst:
	; 左シフトしてLSBを設定
	; eax == 0 -> 0
	; eax == 1 -> 1
	mov ebx,		[q_rst]
	shl ebx, 		1
	or eax,		0
	jz				L_Zero
	bts ebx,		0
L_Zero:
	mov [q_rst], 	ebx
	ret

F_SubFromDivid:
	; if Sub(Dividend - Divisor) >= 0 then [q_rst]:0 = 1
	; else [q_rst]:0 = 0; Dividend += Divisor
	mov eax,	[Q]
	mov ebx,	[M]
	sub eax,	ebx
	mov ebx,	1
	mov [tmp], ebx
	mov ebx,	[M]
	jnc			L_Plus
	add eax,	ebx
	mov ebx,	0
	mov [tmp],	ebx	
L_Plus:
	push rax
	mov eax,	[tmp]
	call 		F_ShiftSetRst
	pop rax
	mov [Q],	eax	
	ret

F_ShftRghtDivisor:
	; M 右シフト
	mov eax,	[M]
	shr eax,	1
	mov [M],	eax
	ret

;***************************************************
;l_div(edi(Q), esi(M), rdx(Remd))
;***************************************************
; Q = Q / M
;全ビットの整数除算
;論理演算による除算関数
;$1:Q			edi(Dividend)
;$2:M			esi(Divisor)
;$3:余り		[rdx](Remainder)
;return		eax(Q)
global l_div
section .text
l_div:
	enter 	0,0
;Initialize
	; 結果バッファをクリア
	; 余りバッファをクリア
	call		F_RsltInit
	; 初期チェク
	; ZF = 1 なら処理中断
	call		F_InitialCheck
	jz			L_ExitMain
	; M (Divisor)のMSBを求めて左シフトして最大値にする（符号なし）
	; QにDividendを格納
	; シフトカウンター格納
	call		F_GetMSBCount
;Main Loop
L_DivLoop:
	; Q = Q - M (Q=余り)
	; 除算結果格納[q_rst]
	call		F_SubFromDivid
	mov eax,	[shf_cnt]
	dec eax
	mov [shf_cnt],	eax
	pushf
	; M Shift Right
	call		F_ShftRghtDivisor
	popf
	jns			L_DivLoop ; プラスならばループ
L_ExitMain:
	mov eax,	[Q] ;余り
	mov [rdx],	eax
	mov eax,	[q_rst] ; 除算結果
	leave
	ret
