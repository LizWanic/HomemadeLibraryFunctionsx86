; Elizabeth Wanic
; 17 February 2017
; CS 3140 - Assignment 4
; Command line for assembly : 
;    nasm -f elf32 start.asm
;	 nasm -f elf32 lib4.asm
; Command line for gcc :
;    gcc -o assign4 -m32 main.c lib4.o start.o -nostdlib \
;         -nodefaultlibs -fno-builtin -nostartfiles
; 
; User must enter ./assign4 to run the program
; enter a file to read from as an argument as required
; 

bits 32         
section .text   
global l_strlen
global l_strcmp
global l_gets
global l_puts
global l_write
global l_open
global l_close
global l_exit

l_strlen:
; int l_strlen(char *str)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; "
	push	edi					; "

	xor 	ecx, ecx 			; zero out ecx to use as len
	mov 	eax, [ebp + 8] 		; move *str to eax

.len_loop_start:
	cmp		byte [eax + ecx], 0x0	; check if char is null
	je 		.len_ret				; jump to return if it is
    inc     ecx                 	; else increment the length
    jmp 	.len_loop_start			; back to top of loop

.len_ret:	
	mov 	eax, ecx 			; put len into eax
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_strcmp:
; int l_strcmp(char *str1, char *str2)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	push 	dword [ebp + 8] 	; *str1
	call 	l_strlen 			; 
	add 	esp, 4 	 	 		; 
	mov 	ebx, eax         	; save len of str1 in ebx

	push 	dword [ebp + 12] 	; *str2
	call 	l_strlen 			;
	add 	esp, 4 				;
	cmp 	ebx, eax 			; compare str lengths 
	jne 	.not_equ 			; jump if not equal

.cmp_loop:
	cmp 	dword eax, 0  			; check for len 0 or full iteration
	je 		.strcmp_ret  			; jump to return in either case
	dec 	eax						; decrement eax
	mov 	ebx, [ebp + 12]			; str2
	mov 	ecx, [ebp + 8] 			; str1
	mov 	dl, [ecx + eax]			; 
	cmp 	[ebx + eax], dl 		; check if chars are equal
	je 		.cmp_loop 				; keep checking if they are, else fall through

.not_equ:
 	mov  	eax, 0x01 			; return 1 if not equal
 	jmp 	.strcmp_ret 		; jump to ret

.strcmp_ret:
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_gets:
; int l_gets(int fd, char *buf, int len)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	mov 	eax, [ebp + 16]     ; len 
	cmp 	dword eax, 0x0 		; check if len is 0
	mov 	esi, 0  			; zero out esi for ret if len 0
	je 		.gets_ret 			; return 0 if it is 

	xor 	esi, esi 			; 0 out esi for byte counter

.gets_loop:
	mov 	eax, [ebp + 16]     ; len
	cmp 	esi, eax 			; check if bytes read equals len 
	je 		.gets_ret 			; return if it does (if equal value already in eax)

	mov eax, 0x03       		; 3 is sys call for read
    mov ebx, [ebp + 8]    		; fd 
    mov ecx, [ebp + 12]   		; *buf
    add ecx, esi				; add offset from the buf pointer
    mov edx, 0x01       		; read one byte at a time
    int 0x80            		; execute read sys call

    cmp 	eax, 0  			; check read's return value
    jle 	.gets_ret			; exit if error or end of file

    mov 	ecx, [ebp + 12]   	; *buf
    add 	ecx, esi			; add offset from the buf pointer
    inc 	esi 				; increment counter of bytes read
	cmp  	byte [ecx], 0x0A	; check for newline 
	je 		.gets_ret	 		; return if last char was newline
	jmp 	.gets_loop 			; else loop to top

.gets_ret:
	mov 	eax, esi 			; return value into eax	
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_puts:
; void l_puts(const char *buf)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	push 	dword [ebp + 8] 	; *buf
	call 	l_strlen 			; eax holds len 
	add 	esp, 4 	 	 		; clean up stack
	
	cmp 	eax, 0 				; check if len == 0
	je 		.puts_ret  			; write nothing if len == 0

	push 	eax 				; len 
	push 	dword [ebp + 8] 	; *buf
	push 	0x01 				; fd for stdout
	call    l_write  			; call l_write 
	add  	esp, 12 			; clean up the stack 

.puts_ret:	
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_write:
; int l_write(int fd, char *buf, int len)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	mov 	eax, 0x04       	; 4 sys call for write
    mov 	ebx, [ebp + 8]      ; fd 
    mov 	ecx, [ebp + 12]     ; *buf
    mov 	edx, [ebp + 16]     ; len
    int 	0x80            	; execute write sys call

    cmp 	eax, 0              ; check value in eax
    jge 	.write_ret	 		; jump to return, value alread in eax

.write_error:
	mov 	dword eax, -1 		; else, error, put -1 in eax

.write_ret:	
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_open:
; int l_open(const char *name, int flags, int mode)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	mov 	eax, 0x05       	; 5 is sys call for open
	mov 	ebx, [ebp + 8]		; *name
	mov 	ecx, [ebp + 12] 	; flags
	mov 	edx, [ebp + 16] 	; mode 
    int 	0x80            	; execute exit sys call	

	cmp 	eax, 0              ; check value in eax
    jl 		.open_error 		; if negative - error
    jmp 	.open_ret	 		; jump to return, value already in eax

.open_error:
	mov 	dword eax, -1 		; -1 is error value

.open_ret:
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_close:
; int l_close(int fd)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "

	mov 	eax, 0x06       	; 6 is sys call for close
	mov 	ebx, [ebp + 8]		; fd 
    int 	0x80            	; execute exit sys call	

	cmp 	eax, 0              ; check value in eax
    jl 		.close_error 		; if negative - error
    jmp 	.close_ret	 		; jump to return, value already in eax

.close_error:
	mov 	dword eax, -1 		; -1 is error value

.close_ret:
	pop		edi             	; Restore non-clobber registers
	pop		esi					; "
	pop 	ebx					; "
	mov 	esp, ebp 			; return esp to original location
	pop 	ebp 				; restore caller's fp
	ret


l_exit:
; int l_exit(int rc)
	push 	ebp 				; save caller's frame pointer
	mov 	ebp, esp 			; setup our frame pointer
	push 	ebx					; Save non-clobber registers
	push	esi             	; 
	push	edi					; "
	mov 	eax, 0x01       	; 1 is sys call for exit
	mov 	ebx, [ebp + 8]		; argument as the return 
    int 	0x80            	; execute exit sys call
	



