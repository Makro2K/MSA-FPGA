#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "MSA_BPM.h"
#include "xil_io.h"
int main()
{
    init_platform();
    u32 N = 10;
	u32 M = 6;
	u32 p[6] = {2,2,2,2,0,0};
	u32 t[10] = {2,2,2,0,2,3,0,0,0,0};
	u32 k;
    print("Start MSA demo app!\n\r");

    Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 0); // Reset MSA BPM Core
    if(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 0)
    {
    	Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG3_OFFSET, M); // Send m data to FPGA
    	Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 1); // Start m analysing
    }
    usleep(5);
    while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 1){}; // Wait until m analysing is done
    for (int i=0; i<M; i++)
    {
    	if(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 2)
    	{
    		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG1_OFFSET, p[i]); // Send p[i] to FPGA
    		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 2); // Start p analysing
    		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 1); // Block next iteration
    	}
    	usleep(5);
    	while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 1){}; // Wait until p analysing is done
    }
    Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 3); // End p-loop, do next operations
    usleep(5);
    while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 1){}; // Wait until done
	{
    	for (int i=0; i<N; i++)
		{
			if(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 3)
			{
				Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG0_OFFSET, t[i]); // Send t[i] to FPGA
				Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 4); // Start p analysing
				Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 1); // Block next iteration
			}
			usleep(5);
			while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 1){}; // Wait until p analysing is done
		}
	}
	k = Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG5_OFFSET);
	printf("K = %d\n\r", k);
    cleanup_platform();
    return 0;
}
