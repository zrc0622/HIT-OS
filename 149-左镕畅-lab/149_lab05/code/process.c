#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <sys/times.h>
#include <sys/wait.h>

#define HZ 100 

void cpuio_bound(int last, int cpu_time, int io_time);

int main(int argc, char * argv[])
{
   pid_t pid_1, pid_2, pid_3; 
   int exit_pid;
   
   printf("parent pid is [%d].\n", getpid()); 

   pid_1 = fork(); 
   if(pid_1 != 0) 
   {
      printf("the child process has been created(pid is [%d]).\n", pid_1);
   }
   if(pid_1 == 0) 
   {
      printf("[%d] is running now.\n", getpid());
      cpuio_bound(10, 1, 0);
      exit(0); 
   }

   pid_2 = fork();
   if(pid_2 != 0) 
   {
      printf("the child process has been created(pid is [%d]).\n", pid_2);
   }
   if(pid_2 == 0)
   {
      printf("[%d] is running now.\n", getpid());
      cpuio_bound(10, 0, 1);
      exit(0);
   }

   pid_3 = fork();
   if(pid_3 != 0) 
   {
      printf("the child process has been created(pid is [%d]).\n", pid_3);
   }
   if(pid_3 == 0)
   {
      printf("[%d] is running now.\n", getpid());
      cpuio_bound(10, 1, 1);
      exit(0);
   }


   exit_pid = wait(NULL);
   printf("[%d] have exited.\n",exit_pid);
   exit_pid = wait(NULL);
   printf("[%d] have exited.\n",exit_pid);
   exit_pid = wait(NULL);
   printf("[%d] have exited.\n",exit_pid);

   printf("the program was executed successfully.\n");

   return 0;
}

void cpuio_bound(int last, int cpu_time, int io_time)
{
   struct tms start_time, current_time;
   clock_t utime, stime;
   int sleep_time;

   while (last > 0)
   {
      /* CPU Burst */

      times(&start_time); 

      do
      {
            times(&current_time); /*不断获取时钟滴答次数*/
            utime = current_time.tms_utime - start_time.tms_utime; /*代表当前进程cpuio_bound函数在用户态下运行的时钟滴答次数*/
            stime = current_time.tms_stime - start_time.tms_stime; /*代表当前进程cpuio_bound函数在内核态下运行的时钟滴答次数*/
      } while ( ( (utime + stime) / HZ )  < cpu_time );
      
      last -= cpu_time;

      if (last <= 0 ){break;}


      /* IO Burst */

      /* 用sleep(1)模拟1秒钟的I/O操作 */
      sleep_time=0;
      while (sleep_time < io_time)
      {
            sleep(1); /*系统调用，暂停1s*/
            sleep_time++;
      }
      last -= sleep_time;
   }
}