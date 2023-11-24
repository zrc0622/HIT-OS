!
!	setup.s		(C) 1991 Linus Torvalds
!
! setup.s is responsible for getting the system data from the BIOS,
! and putting them into the appropriate places in system memory.
! both setup.s and system has been loaded by the bootblock.
!
! This code asks the bios for memory/disk/other parameters, and
! puts them in a "safe" place: 0x90000-0x901FF, ie where the
! boot-block used to be. It is then up to the protected mode
! system to read them from there before the area is overwritten
! for buffer-blocks.
!

! NOTE! These had better be the same as in bootsect.s!

INITSEG  = 0x9000	! we move boot here - out of the way
SYSSEG   = 0x1000	! system loaded at 0x10000 (65536).
SETUPSEG = 0x9020	! this is the current segment

.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

entry start
start:
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	
	mov	cx,#23
	mov	bp,#msg1
	call print_msg

! ok, the read went well so we get current cursor position and save it for
! posterity.
	mov	ax,#INITSEG	! this is done in bootsect already, but...
	mov	ds,ax
	mov	ah,#0x03	! read cursor pos
	xor	bh,bh
	int	0x10		! save it in known place, con_init fetches
	mov	[0],dx		! it from 0x90000.

! Get memory size (extended mem, kB)
	mov	ah,#0x88
	int	0x15
	mov	[2],ax

!从0x41处拷贝16个字节(磁盘参数表)
	mov    ax,#0x0000
	mov    ds,ax
	lds    si,[4*0x41]	!中断向量偏移,x86下一个地址寻址一个字节,1字=2字节=16位
	mov    ax,#INITSEG
	mov    es,ax		!目标地址0x9000
	mov    di,#0x0004	!目标地址偏移4
	mov    cx,#0x10		!重复16次
	rep            
	movsb

!打印光标位置
	mov cx,#11
	mov bp,#msg2 !es:bp为字符串地址
	call print_msg
	
	mov bp,#0
	call print_hex
	call print_nl

!打印内存大小
!先确定光标位置
	mov	ah,#0x03		
	xor	bh,bh
	int	0x10
!打印提示信息“Memory SIZE:”
	mov cx,#12	! 设置字符串长度
	mov bp,#msg3	! 设置字符串偏移地址
	call print_msg	! 在函数内部设置es的值,es:bp指向要打印的字符串(es相当于栈基址(es为#SETUPSEG),bp相当于栈偏移)
!打印内存大小
	mov bp,#2	! 设置保存了内存大小的栈偏移地址
	call print_hex	! 在函数内部设置es的值,es:bp指向要打印的内存大小(es为#INITSEG)
!确定光标位置
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
!打印“KB”
	mov cx,#2
	mov bp,#msg4
	call print_msg
	call print_nl	! 打印换行
	call print_nl

! 打印其它信息
	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov cx,#7
	mov bp,#msg5
	call print_msg
	call print_nl

	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov cx,#10
	mov bp,#msg6
	call print_msg
	mov bp,#0x4
	call print_hex
	call print_nl

	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov cx,#8
	mov bp,#msg7
	call print_msg
	mov bp,#0x6
	call print_hex
	call print_nl

	mov	ah,#0x03		! read cursor pos
	xor	bh,bh
	int	0x10
	mov cx,#8
	mov bp,#msg8
	call print_msg
	mov bp,#0x12
	call print_hex
	call print_nl

! 进入死循环,不再加载Linux内核
pause:
	jmp pause

! 以16进制方式打印栈顶的16位数
print_hex:
	mov ax,#INITSEG		 ! 初始化es 
	mov es,ax
    mov    cx, #4        ! 4个十六进制数字(计数器设置为4,每打印一次cx减1)
    mov    dx, (bp)      ! 将(bp)所指的值放入dx中,如果bp是指向栈顶的话,(dx为16位寄存器)
print_digit:
    rol    dx, #4        ! 循环以使低4比特用上,取dx的高4比特移到低4比特处(一次取4位,代表一个十六进制数)。
    mov    ax, #0xe0f    ! ah = 请求的功能值,al = 半字节(4个比特)掩码。
    and    al, dl        ! 取dl的低4比特值。
    add    al, #0x30     ! 给al数字加上十六进制0x30
    cmp    al, #0x3a
    jl     outp           ! 是一个不大于十的数字
    add    al, #0x07      ! 是a~f,要多加7
outp:
    int    0x10           ! 调用BIOS中断0x10,显示字符
    loop   print_digit    ! 循环，继续处理下一个数字
    ret

print_nl:
    mov    ax,#0xe0d   ! CR
    int    0x10
    mov    al,#0xa     ! LF
    int    0x10
    ret

!将打印也封装成函数,注意调用前需要把cx赋字符串长度,bp赋字符串位置
print_msg:
	mov	ax,#SETUPSEG
	mov	es,ax !初始化es
	mov bx, #0x0007
	mov ax, #0x1301
	int 0x10
	ret

msg1:
	.ascii "Now we are in SETUP"
	.byte 13,10,13,10

msg2:
	.ascii "Cursor POS:" ! 11

msg3:
	.ascii "Memory SIZE:" ! 12

msg4:
	.ascii "KB" ! 2

msg5:
	.ascii "HD Info" ! 7

msg6:
	.ascii "Cylinders:" ! 10 柱面数

msg7:
	.ascii "Headers:" ! 8 磁头数

msg8:
	.ascii "Sectors:" ! 8 扇区数


.text
endtext:
.data
enddata:
.bss
endbss:
