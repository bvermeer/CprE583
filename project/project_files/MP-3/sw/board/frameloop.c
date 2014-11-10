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

/* Set the run mode as a compile-time constant */
#ifndef MODE
#define MODE 1
#endif


/* SVGA configuration variables */
struct svgactrlregs *regs;
format_s *f;

int main()
{
	uint32_t *fbase, *imageaddr, *graybuffer;
	uint32_t i, j;
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
			case 2: /* Floating point grayscale conversion */
				mode2(fbase, imageaddr);
				break;
			/* Add more cases for new modes */
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
