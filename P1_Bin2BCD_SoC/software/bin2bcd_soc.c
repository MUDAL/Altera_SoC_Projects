// Author: Olaoluwa Raji

// Date: 31/08/2026

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define HW_REGS_BASE        (ALT_STM_OFST)
#define HW_REGS_SPAN          (0x04000000)
#define HW_REGS_MASK    (HW_REGS_SPAN - 1) 

enum Register_Offsets
{
    STATUS_REG_OFFSET        = 0x00,
    CONTROL_REG_OFFSET       = 0x04,
    INPUT_DATA_REG_OFFSET    = 0x08,
    OUTPUT_DATA1_REG_OFFSET  = 0x0C,
    OUTPUT_DATA2_REG_OFFSET  = 0x10
};

typedef struct
{
    void* status;
    void* control;
    void* input_data;
    void* output_data1;
    void* output_data2; 
}reg_t;

void* get_virtual_addr(void* virtual_base_addr, uint8_t reg_offset)
{
    uint32_t offset = (ALT_LWFPGASLVS_OFST + BIN2BCD_MM_PERIPH_0_BASE + reg_offset) & (HW_REGS_MASK);
    return virtual_base_addr + offset;
}

int main(void)
{
    int      retVal       = 0;
    int      fd           = 0;
    void*    virtual_base = NULL;
    reg_t    reg          = {};
    uint32_t input        = 0;
    uint32_t low_word     = 0;
    uint32_t high_word    = 0;

    if((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
    {
        printf("ERROR: Could not open \"/dev/mem\"...\r\n");
        retVal = 1;
    }
    else
    {
        virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, HW_REGS_BASE);

        if(virtual_base == MAP_FAILED)
        {
            printf("ERROR: mmap() failed...\r\n");
            close(fd);
            return 1;
        }
        else
        {
            reg.status       = get_virtual_addr(virtual_base, STATUS_REG_OFFSET);
            reg.control      = get_virtual_addr(virtual_base, CONTROL_REG_OFFSET);
            reg.input_data   = get_virtual_addr(virtual_base, INPUT_DATA_REG_OFFSET);
            reg.output_data1 = get_virtual_addr(virtual_base, OUTPUT_DATA1_REG_OFFSET);
            reg.output_data2 = get_virtual_addr(virtual_base, OUTPUT_DATA2_REG_OFFSET);

            *(volatile uint32_t*)reg.control = (1<<0); // Enable the bin2bcd memory-mapped peripheral
            printf("Bin2BCD memory-mapped peripheral enabled\n");

            while(1) 
            {
                printf("Enter the input: ");
                scanf("%d", &input);
                *(volatile uint32_t*)reg.input_data = input;       // Load Input Data Register
                while(*(volatile uint32_t*)reg.status != (1<<1)){} // Wait for DONE bit to be set
                // Read the Output Data Registers 
                low_word  = *(volatile uint32_t*)reg.output_data1;
                high_word = *(volatile uint32_t*)reg.output_data2;              
                printf("BCD data = %x-%x\n", high_word, low_word);
            }

            if(munmap(virtual_base, HW_REGS_SPAN) != 0)
            {
                printf("ERROR: munmap() failed...\r\n");
                retVal = 1;
            }
            close(fd);
        }
    }
    return retVal;
}