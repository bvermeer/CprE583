/*****************************************************************************
 * Joseph Zambreno
 * Department of Electrical and Computer Engineering
 * Iowa State University
 *****************************************************************************/


/*****************************************************************************
 * frameloop.c - grabs a series of frames from memory and copies them to the
 * framebuffer, after (optionally) applying some filters. 
 *
 *
 * NOTES:
 * 10/26/12 by JAZ::Design created.
 * 8/1/13 by TJB::Completed base for video image processing.
 *****************************************************************************/

#include "frameloop.h"
#include "coproc.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

//#include "hackaday_logo.h"

/* Set the run mode as a compile-time constant */
#ifndef MODE
#define MODE 4
#endif


/* SVGA configuration variables */
struct svgactrlregs *regs;
format_s *f;

int main()
{
	uint32_t *fbase, *imageaddr, *graybuffer;
	uint32_t i, j, k;
	float time, fps;
	clock_t t1, t2;

	cp_en(); /* Enable the coprocessor */
	fbase = svga_enable(); /* Configure and enable the svga controller */
	imageaddr = (uint32_t*)STARTADDR; /* Set the address of the first image */

	t1 = clock(); /* Get the start time */

    for (i = 0; i < NFRAMES; i++)
    {
    	switch(MODE)
    	{
    		default:
    		case 1: /* Copy images to framebuffer */
    			mode1(fbase, imageaddr);
    			break;
    		case 2: /* Floating point grayscale conversion in software */
    			mode2(fbase, imageaddr);
    			break;
    		/* Add more cases for new modes */
    		case 3: /* Fixed point grayscale conversion in software */
    			mode3(fbase, imageaddr);
    			break;
    		case 4: /* Mode to use the fixed point grayscale coprocessor */
    			mode4(fbase, imageaddr);
    			break;
    		case 5: /* Mode to do the Laplacian edge detection in software  */
    			mode5(fbase, imageaddr);
    			break;
    		// case 7: /* "Hack" the screen! */
    		// 	hackmode(fbase, imageaddr);
    		// 	break;
    	}

    	imageaddr += f->hactive_video*f->vactive_video/2; /* Move to the next image */
    }

    /* Report the time to process the frames */
    t2 = clock();
    time = (t2 - t1) / CLOCKS_PER_SEC;
    fps = NFRAMES / time;
    printf("FPS: %f\n", fps);
    t1 = t2;


	return 0;
}


/* Default mode - copies the current frame to the frame buffer */
inline void mode1(uint32_t *fbase, uint32_t *imageaddr)
{
	uint32_t x;

	for (x = 0; x < f->hactive_video*f->vactive_video/2; x++)
	{
		fbase[x] = imageaddr[x];
	}
}

/* Mode 2 - floating-point grayscale conversion */
inline void mode2(uint32_t *fbase, uint32_t *imageaddr)
{
	uint32_t x;

	/* Y = 0.299*R + 0.587*G + 0.114*B */
	/* 640x480 resolution, 16-bit pixels in 5-6-5 format  */
	/* hactive_video = 640, vactive_video = 480 */

	uint16_t *fbase2, *imageaddr2;
	uint32_t R1, R2, G1, G2, B1, B2;
	float Y1, Y2;

	fbase2 = (uint16_t *)fbase;
	imageaddr2 = (uint16_t *)imageaddr;

	for (x = 0; x < f->hactive_video*f->vactive_video/2; x++)
	{
		R1 = (uint16_t)((imageaddr[x] & 0x0000F800) >> 11);
		R2 = (uint16_t)((imageaddr[x]) >> 27);

		G1 = (uint16_t)((imageaddr[x] & 0x000007E0) >> 5);
		G2 = (uint16_t)((imageaddr[x] & 0x07E00000) >> 21);

		B1 = (uint16_t)(imageaddr[x] & 0x0000001F);
		B2 = (uint16_t)((imageaddr[x] & 0x001F0000) >> 16);

		Y1 = 0.299*(float)R1/31.0 + 0.587*(float)G1/63.0 + 0.114*(float)B1/31.0;
		Y2 = 0.299*(float)R2/31.0 + 0.587*(float)G2/63.0 + 0.114*(float)B2/31.0;


		R1 = (uint32_t)(Y1*31);
		G1 = R1*2;
		B1 = R1;

		R2 = (uint32_t)(Y2*31);
		G2 = R2*2;
		B2 = R2;


		fbase[x] = ((R1 << 11) | (G1 << 5) | (B1)) | ((R2 << 27) | (G2 << 21) | (B2 << 16));
	}
}


/* Mode 3 - fixed-point grayscale conversion */
inline void mode3(uint32_t *fbase, uint32_t *imageaddr)
{
	uint32_t x;

	/* Y = 0.299*R + 0.587*G + 0.114*B */
	/* 640x480 resolution, 16-bit pixels in 5-6-5 format  */
	/* hactive_video = 640, vactive_video = 480 */

	uint16_t *fbase2, *imageaddr2;
	uint32_t R1, R2, G1, G2, B1, B2;
	uint32_t Y1, Y2;

	fbase2 = (uint16_t *)fbase;
	imageaddr2 = (uint16_t *)imageaddr;

	for (x = 0; x < f->hactive_video*f->vactive_video/2; x++)
	{
		R1 = (uint16_t)((imageaddr[x] & 0x0000F800) >> 11);
		R2 = (uint16_t)((imageaddr[x]) >> 27);

		G1 = (uint16_t)((imageaddr[x] & 0x000007E0) >> 5);
		G2 = (uint16_t)((imageaddr[x] & 0x07E00000) >> 21);

		B1 = (uint16_t)(imageaddr[x] & 0x0000001F);
		B2 = (uint16_t)((imageaddr[x] & 0x001F0000) >> 16);

		Y1 = 158*R1 + 152*G1 + 60*B1;
		Y2 = 158*R2 + 152*G2 + 60*B2;

		R1 = (Y1 & 0x3E00) >> 9;
		G1 = R1*2;
		B1 = R1;

		R2 = (Y2 & 0x3E00) >> 9;
		G2 = R2*2;
		B2 = R2;


		fbase[x] = ((R1 << 11) | (G1 << 5) | (B1)) | ((R2 << 27) | (G2 << 21) | (B2 << 16));
	}
}


/* Mode 4 - fixed-point grayscale conversion with coprocessor */
inline void mode4(uint32_t *fbase, uint32_t *imageaddr)
{
	/* Y = 0.299*R + 0.587*G + 0.114*B */
	/* 640x480 resolution, 16-bit pixels in 5-6-5 format  */
	/* hactive_video = 640, vactive_video = 480 */
	
    uint32_t x;


	for (x = 0; x < f->hactive_video*f->vactive_video/2; x+=2)
	{
        // Load the next 4 pixels to be processed (16 bits per pixel)
        ld_c0(imageaddr[x]);
        ld_c2(imageaddr[x+1]);

        // Call the coprocessor to process the 4 input pixels 
        // Instruction format: IN1, IN2, OUTPUT
	    asm(cpop1(CP_COLOR_2_BW, "0x0", "0x2", "0x4"));

        // Store the 4 BW pixels to the output framebuffer
        st_c4(&(fbase[x]));
        st_c5(&(fbase[x+1]));


        //DEBUG
        // if(x == 0)
        // {
        //     printf("First two pixels: 0x%x\n"
        //             "Next two pixels: 0x%x\n"
        //             "Output 1: 0x%x\n"
        //             "Output 2: 0x%x\n", imageaddr[x], imageaddr[x+1], fbase[x], fbase[x+1]);
	    //     
        // }
	}
}


/* Mode 5 - Laplacian edge detection in software */ 
inline void mode5(uint32_t *fbase, uint32_t *imageaddr)
{
	uint32_t x, y;

	/* Y = 0.299*R + 0.587*G + 0.114*B */
	/* 640x480 resolution, 16-bit pixels in 5-6-5 format  */
	/* hactive_video = 640, vactive_video = 480 */

    // Temporary pixels to use for Laplacian kernel
    int32_t ul, uc, ur, cl, c, cr, ll, lc, lr, tmp; 

    // Test to see if assumption on array index is correct.
	uint16_t (*fbase2d)[f->hactive_video] = (uint16_t (*)[f->hactive_video])&fbase[0];
    
    uint32_t *grayscale_img = (uint32_t *)malloc(2*f->hactive_video*f->vactive_video);

    uint16_t (*grayscale_img2d)[f->hactive_video]= (uint16_t (*)[f->hactive_video])&grayscale_img[0];

    if(grayscale_img == 0)
    {
        printf("ERROR: Out of memory!\n");
    }

    
    if(imageaddr == 0x41e4c000)
    {
	    for (x = 0; x < f->hactive_video*f->vactive_video/2; x++)
	    {
	    	fbase[x] = imageaddr[x];
	    }
    }
    else
    {
    
        // Used the fixed point software grayscale mode to get a grayscale image
        mode3(grayscale_img, imageaddr);


        for(y = 1; y < (f->vactive_video - 1); y++)
        {
            for(x = 1; x < (f->hactive_video - 1); x++)
            {
                // Edge case to load initial pixels
                if(x == 1)
                {
                    ul = grayscale_img2d[y-1][0];
                    uc = grayscale_img2d[y-1][1];
                    cl = grayscale_img2d[y][0];
                    c  = grayscale_img2d[y][1];
                    ll = grayscale_img2d[y+1][0];
                    lc = grayscale_img2d[y+1][1];
                }

                ur = grayscale_img2d[y-1][x+1];
                cr = grayscale_img2d[y][x+1];
                lr = grayscale_img2d[y+1][x+1];

                tmp = ((8*c) - ul - uc - ur - cl - cr - ll - lc - lr);

                if(tmp < 0)
                {
                    fbase2d[y][x] = 0;
                }
                else if(tmp > 65535)
                {
                    
                    fbase2d[y][x] = 0xFFFF; 
                }
                else
                {
                    fbase2d[y][x] = tmp & 0xFFFF;
                }

            }
        }
   
    }
   
   // Free the memory we used for the temporary image
   free(grayscale_img); 
}


inline void mode6(uint32_t *fbase, uint32_t *imageaddr){

	uint32_t x, y;

	uint32_t (*imageaddr_2d)[f->hactive_video/2]= (uint32_t (*)[f->hactive_video/2])&imageaddr[0];
	uint32_t (*fbase_2d)[f->hactive_video/2]= (uint32_t (*)[f->hactive_video/2])&fbase[0];

	for(y = 1; y < (f->vactive_video - 1); y++){
		ld_c0(imageaddr_2d[y-1][0]);
		ld_c2(imageaddr_2d[y][0]);
		ld_c4(imageaddr_2d[y+1][0]);

		//Grayscale conversion
		asm(cpop1(CP_COLOR_2_BW, "0x0", "0x2", "0x0"));
		asm(cpop1(CP_COLOR_2_BW, "0x4", "0x2", "0x2"));

		asm(cpop1(CP_PRELOAD, "0x0", "0x2", "0x4"));

		for (x = 1; x < (f->hactive_video)/2 - 1; x++)
		{
        	// Load the next 4 pixels to be processed (16 bits per pixel)
        	ld_c0(imageaddr_2d[y-1][x]);
			ld_c2(imageaddr_2d[y][x]);
        	ld_c4(imageaddr_2d[y+1][x]);
        	
       		// if(x == y){
			// 	ld_c0(0);
			// 	ld_c1();
			// 	ld_c2(0);
			// }else if(x == (y - 1) || x == (y + 20)){
			// 	ld_c0(0);
			// 	ld_c1(2016);
			// 	ld_c2(0);
			// }else{
			// 	ld_c0(0);
			// 	ld_c1(0);
			// 	ld_c2(0);
			// }
	
        	// Call the coprocessor to process the 4 input pixels 
        	// Instruction format: IN1, IN2, OUTPUT
		    asm(cpop1(CP_COLOR_2_BW, "0x0", "0x2", "0x0"));
		    asm(cpop1(CP_COLOR_2_BW, "0x4", "0x2", "0x2"));

		    asm(cpop1(CP_EDGE_DETECT, "0x0", "0x2", "0x4"));

        	// Store the 4 BW pixels to the output framebuffer
        	st_c4(&(fbase_2d[y][x]));
        	
		}
	}

}

/* Default mode - copies the current frame to the frame buffer */
// inline void hackmode(uint32_t *fbase, uint32_t *imageaddr)
// {
//     uint32_t x;
// 
// 	for (x = 0; x < f->hactive_video*f->vactive_video/2; x++)
// 	{
// 		fbase[x] = (hackaday_logo[2*x]<<16) | hackaday_logo[2*x+1];
// 	}
// }




/* DO NOT MODIFY */
uint32_t *svga_enable()
{
	int i, x, vec[3];
	int found = 0;
	int clock;
	uint32_t *fbase;

	regs = (struct svgactrlregs*)SVGACTRL_ADDR;

	regs->stat = 0;

	for (clock = 0; clock < 4; clock++)
	{
		if (formats[FORMAT].period == regs->dclock[clock])
		{
			found = 1;
			break;
		}
	}

	if (!found)
	{
		fail(0);
	}

	f = &formats[FORMAT];

	regs->vidlen = ((f->vactive_video-1) << 16)  | (f->hactive_video-1);
	regs->fporch = ((f->vfporch) << 16)  | (f->hfporch);
	regs->synclen = ((f->vsync) << 16)  | (f->hsync);
	regs->linelen = (((f->vactive_video-1 + f->vfporch + f->vsync + f->vbporch) << 16) | (f->hactive_video-1 + f->hfporch + f->hsync + f->hbporch));

	/* Allocate framebuffer */
	fbase = memalign(1024, 2*f->hactive_video*f->vactive_video);
	if (fbase == NULL)
	{
		fail(1);
	}

	printf("Allocated framebuffer at location %08x\n", fbase);

	regs->framebuf = (int)fbase;

	/* Enable controller */
	regs->stat = ((clock << SVGACTRL_CLKSEL) | (2 << SVGACTRL_BDSEL) | (1 << SVGACTRL_EN));

	return fbase;
}


/* DO NOT MODIFY */
void svga_disable(uint32_t *fbase)
{
	regs->stat = 0;
	free(fbase);

	return;
}
