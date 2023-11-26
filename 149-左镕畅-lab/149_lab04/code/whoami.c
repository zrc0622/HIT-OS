#define __LIBRARY__
#include <unistd.h>
#include <stdio.h>

_syscall2(int, whoami, char*, name, unsigned int, size);

int main(int argc,char* argv[])
{
   char tempstr[24];
   whoami(tempstr,24); 
   printf("%s\n",tempstr);
   return 0;
}