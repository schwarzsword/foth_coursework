%include "macro.inc"
%include "lib.inc"
%include "words.inc"

%define pc r12
%define w r13
%define rstack r14

section .data
last_word: 	dq link
rsp_b: 		dq 0
no_word: 	db ' no such word', 10, 0
here: 		dq dict
xt_exit: 	dq exit
program_stub: 	dq 0
xt_interpreter: dq .interpreter
.interpreter: 	dq interpreter_loop

section .text
global _start
_start:
	mov rstack, rs + 65536 * 8
	mov [rsp_b], rsp
    	mov pc, xt_interpreter
    	jmp next

interpreter_loop:
    	cmp qword [state], 0  		; check mode
    	jne compiler_loop

	xor rax, rax
	mov qword [word_buffer], rax
	mov rdi, word_buffer
	call read_word		    	; word_buffer <- stdin
	cmp qword [word_buffer], 0x00
	jz .EOF			            		 
	call find_word			; try as defined word
					; rax <- w_word
	test rax, rax
	jz .parse_number	    	; if !(word in dict) -> try parse as number

	mov rdi, rax
	call cfa		        ; else rax <- xt_word

	mov [program_stub], rax
	mov pc, program_stub		; ptr to next ex token = found xt_word
	jmp next
.parse_number:
	mov rdi, word_buffer
	call parse_int

	test rdx, rdx
	jz .no_word		        ; if lenght == 0 rip

	push rax		        ; else push n
	mov pc, xt_interpreter
	jmp next
.no_word:
	call print_no_word
	mov pc, xt_interpreter
	jmp next
.EOF:
	mov rax, 60
    	xor rdi, rdi
    	syscall


compiler_loop:
    	cmp qword [state], 1      	; check mode
    	jne interpreter_loop

    	mov rdi, word_buffer
    	call read_word              	; word_buffer <- stdin
    	call find_word              	; try as defined word 
					; rax <- w_word
	test rax, rax
    	jz .parse_number	        ; if !(word in dict) -> try parse as number

    	mov rdi, rax
    	call cfa		        ; else rax <- xt_word

    	cmp byte [rax - 1], 1		; check as immediate
    	je .immediate               
	
    	mov rdi, [here]			; else add xt to here
   	mov [rdi], rax              	
   	add qword [here], 8
    	jmp compiler_loop
.parse_number:
    	mov rdi, word_buffer
    	call parse_int

    	test rdx, rdx
    	jz .no_word		        ; if lenght == 0 rip

	mov rdi, [here]
    	cmp qword [rdi - 8], xt_branch	; check if prev == branch/branch0
	je .branch
	cmp qword [rdi - 8], xt_branch0
	je .branch

    	mov rdi, [here]			; else add xt_lit
    	mov qword [rdi], xt_lit     	
    	add qword [here], 8
.branch:
	mov rdi, [here]			; add num
	mov [rdi], rax
	add qword [here], 8
	jmp compiler_loop
.immediate:
    	mov [program_stub], rax
    	mov pc, program_stub
    	jmp next
.no_word:
	call print_no_word
    	mov pc, xt_interpreter
	jmp next

next:
    	mov w, pc		; ptr to current xt_word
    	add pc, 8		; set pc as ptr to next xt (xt_interpreter / (xt_word or xt_exit) for colon)
    	mov w, [w]		; ptr to word_impl or docol
    	jmp [w]			; jmp to word_impl or docol

docol:
	sub rstack, 8		
	mov [rstack], pc	; save ptr to next xt
	add w, 8	    	
	mov pc, w	    	
	jmp next	    	

exit:
	mov pc, [rstack]	; restore ptr to next xt
	add rstack, 8		
	jmp next	
