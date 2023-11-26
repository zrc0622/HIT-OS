#include <asm/segment.h> 
#include <errno.h> 

char msg[24]; 
int len = 0; 

int sys_iam(const char* name)
{
    int count = 0;
    while(get_fs_byte(name+count) != '\0') 
    {
        if(count >= 23) 
        {
            return -(EINVAL);
        }
        count = count + 1;
    }
    len = count;
    for(count = 0; count < len; count++)
    {
		msg[count] = get_fs_byte(name+count);
    }
    return len;
}

int sys_whoami(char* name, unsigned int size)
{
    int i = 0;
    if(len > size)
    {
        return -(EINVAL);
    }
    for(i=0; i<len; i++)	
    {
        put_fs_byte(msg[i], name+i);
    }
    return len;
}