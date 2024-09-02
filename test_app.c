#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define MAP_SIZE 4096   // 4096 bytes as per DTSO file
#define BASE_ADDRESS 0x43C00000
#define OFFSET_REG0 0  // First number
#define OFFSET_REG1 4   // Second number
#define OFFSET_REG2 8   // Result of addition

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

    //Write first number
    *((volatile uint32_t *)(mapped_base + OFFSET_REG0)) = 8;
    
    //Write second number
    *((volatile uint32_t *)(mapped_base + OFFSET_REG1)) = 5;
    
    //Read result
    uint32_t value = *((volatile uint32_t *)(mapped_base + OFFSET_REG2));
    
    printf("Result: %d\n\r", value);
    munmap(mapped_base, length);
    close(mem_fd);

    return 0;
}
