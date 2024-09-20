#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>

#define MAP_SIZE 4096   // 4096 bytes as per DTSO file
#define BASE_ADDRESS 0x43C00000
#define OFFSET_REG0 0  // First number
#define OFFSET_REG1 4   // Second number
#define OFFSET_REG2 8   // Result of addition
#define OFFSET_REG3 12
#define OFFSET_REG4 16
#define OFFSET_REG5 20
#define OFFSET_REG6 24

int main() {
    int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (mem_fd == -1) {
        printf("Error: cannot open /dev/mem\n");
        return -1;
    }

    // Calculate the offset within the mapped region
    off_t offset = BASE_ADDRESS;
    size_t length = MAP_SIZE;

    void *mapped_base = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, offset);
    if (mapped_base == MAP_FAILED) {
        perror("Failed to map memory");
        close(mem_fd);
        return -1;
    }

    clock_t start, end;
    double cpu_time_used;
    uint32_t test;
    start = clock();
    uint32_t N = 6;
	uint32_t M = 1;
	//u32 p[2] = {2,2,2,2,0,0};
	uint32_t t[6] = {2,0,0,0,0,0};
	uint32_t k;
    printf("Start MSA Linux demo app!\n\r");

    *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 0;
    if(*((volatile uint32_t *)(mapped_base + OFFSET_REG6)) == 0)
    {
        *((volatile uint32_t *)(mapped_base + OFFSET_REG3)) = M;
        *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 1;
        test = *((volatile uint32_t *)(mapped_base + OFFSET_REG6));
        printf("status 1 = %d\n\r", test);
    }
    printf("M loaded\n\r");
    //usleep(5);
    while(*((volatile uint32_t *)(mapped_base + OFFSET_REG6)) == 1){};

    for (int i=0; i<M;i++)
    {   
        printf("Start p loop\n\r");
        test = *((volatile uint32_t *)(mapped_base + OFFSET_REG6));
        printf("status 2 = %d\n\r", test);
        while(test !=2){};
        //while(*((volatile uint32_t *)(mapped_base + OFFSET_REG6)) != 2){};
        printf("After while\n\r");
        *((volatile uint32_t *)(mapped_base + OFFSET_REG1)) = 2;
        *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 2;
    }
    printf("p loop ended\n\r");
    *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 3;
    
    for (int i=0; i<N;i++)
    {
        while(*((volatile uint32_t *)(mapped_base + OFFSET_REG6)) != 3){};
        *((volatile uint32_t *)(mapped_base + OFFSET_REG1)) = t[i];
        *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 4;
    }
    printf("t loop ended\n\r");
    *((volatile uint32_t *)(mapped_base + OFFSET_REG4)) = 5;
    //Read result
    k = *((volatile uint32_t *)(mapped_base + OFFSET_REG5));
    
    printf("K = %d\n\r", k);
    munmap(mapped_base, length);
    close(mem_fd);

    end = clock();
    cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;

    printf("Time = %f\n\r", cpu_time_used);
    return 0;
}
