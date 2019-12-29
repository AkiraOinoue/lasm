;lmul(edi, esi(lh), edx(rh))
;全ビットの乗算
;論理演算による乗算関数
;$1:ビット数		edi
;$2:lh			esi
;$3:rh			edx
;return		eax
extern ladd
global lmul
section .data
section .bss
retv		resd	1
MAXBIX		resd	1
lmul.Cnt	resd	1
lmul.LH	resd	1
lmul.RH	resd	1
section .text
lmul:
	enter 	0,0
	mov ecx,			0
	mov [lmul.Cnt], 	ecx
	mov [MAXBIX],		edi
	mov [lmul.LH],		esi	
	mov [lmul.RH],		edx
	mov eax,			0
	mov [retv],		eax
Loop.lmul:
; eax = lh * rh
	mov edi,		[MAXBIX]
	mov ecx,		[lmul.Cnt]
	cmp ecx,		edi; ビットカウンタに到達したか
	je	Break.Loop; ループ処理脱出
	mov eax,		[lmul.RH]
	shr eax,		cl
	and al,		1
	cmp al,		1
	jne Continue.Loop

	mov esi,		[lmul.LH]
	shl esi,		cl		; shift left lh
	mov edx,		esi		; rh <- lh
	mov esi,		[retv]	; lh
	call ladd
	mov [retv],	eax

Continue.Loop:	
	mov ecx,			[lmul.Cnt]
	inc ecx
	mov [lmul.Cnt],	ecx
	jmp Loop.lmul

Break.Loop:
	mov eax,	[retv]
	leave
	ret
