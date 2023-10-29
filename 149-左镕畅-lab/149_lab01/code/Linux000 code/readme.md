## 改动 1
`head.s` 文件里首行加上 `.code32`

## 改动 2

`Makefile` 文件中， `head.o` : `head.s` 下面增加一行

```c
gcc -m32 -c head.s
```

   参数 `-m32` 使得产生的目标文件是32位的，否则64位机编译会出错

## 查看反汇编

```c
gcc -m32 -c -g head.s
objdump -D head.o
```

```c
as86 -l boot.lst boot.s
```

编译成功！


by Dr. GuoJun LIU

Updated on 2020-03-26
