#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "MSA_BPM.h"
#include "xil_io.h"
#include "xtime_l.h"

int main()
{
    init_platform();

    XTime start, end;

    XTime_GetTime(&start);
    u32 N = 11;
	u32 M = 1;
	//u32 p[2] = {2,2,2,2,0,0};
	u32 t[11] = {3,0,0,0,0,0,0,0,0,0,0};
	u32 k;
    print("Start MSA demo app!\n\r");
    //usleep(1000);
    Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 0); // Reset MSA BPM Core
    if(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 0)
    {
    	Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG3_OFFSET, M); // Send m data to FPGA
    	Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 1); // Start m analysing
    }
    //usleep(5);
    while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) == 1){}; // Wait until m analysing is done
    for (int i=0; i<M; i++)
    {
    	while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) != 2){};

		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG1_OFFSET, 2); // Send p[i] to FPGA
		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 2); // Start p analysing
    }
    Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 3); // End p-loop, do next operations

	for (int i=0; i<N; i++)
	{
		while(Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG6_OFFSET) != 3){};
		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG0_OFFSET, t[i]); // Send t[i] to FPGA
		Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 4); // Start t analysing
	}

	Xil_Out32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG4_OFFSET, 5);

	k = Xil_In32(XPAR_MSA_BPM_0_S00_AXI_BASEADDR + MSA_BPM_S00_AXI_SLV_REG5_OFFSET);
	printf("K = %d\n\r", k);
	XTime_GetTime(&end);
	//cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
	printf("Time = %2.f us \n\r", 1.0 * (end - start) / (COUNTS_PER_SECOND/1000000));
    cleanup_platform();
    return 0;
}
