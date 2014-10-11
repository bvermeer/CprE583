/*****************************************************************************
 * Joseph Zambreno
 * Department of Electrical and Computer Engineering
 * Iowa State University
 *****************************************************************************/


/*****************************************************************************
 * frameloop.h - grabs a series of frames from memory and copies them to the
 * framebuffer, after (optionally) applying some filters. 
 *
 *
 * NOTES:
 * 10/26/12 by JAZ::Design created.
 *****************************************************************************/


#ifndef _FRAMELOOP_H_
#define _FRAMELOOP_H_


#include <stdio.h>
#include <malloc.h>
#include <stdint.h>
#include <time.h>

#include "testmod.h"
#include "../data/nframes.h"


#define RED   0xF800
#define GREEN 0x07E0
#define BLUE  0x001F

#define SVGACTRL_ADDR 0x80000600;

/* Status register field positions */

#define SVGACTRL_CLKSEL 6
#define SVGACTRL_BDSEL  4
#define SVGACTRL_EN     0

struct svgactrlregs {
   volatile unsigned int stat;
   volatile unsigned int vidlen;
   volatile unsigned int fporch;
   volatile unsigned int synclen;
   volatile unsigned int linelen;
   volatile unsigned int framebuf;
   volatile unsigned int dclock[4];
   volatile unsigned int clut;
};

typedef struct {
   const char *name;
   int period; /* Clock period in ps */
   /* Horizontal (in Pixels) */
   int hactive_video;
   int hfporch;
   int hsync;
   int hbporch;
   /* Vertical (in lines) */
   int vactive_video;
   int vfporch;
   int vsync;
   int vbporch;
} format_s;

#define NUM_FORMATS 17
#define TEST_FORMAT 16
#define FORMAT 2

static format_s formats[NUM_FORMATS] = {
   /* 0 */
   { 
      .name = "480x272, ",
      .period = 111111,
      .hactive_video = 480,
      .hfporch = 2,
      .hsync = 1,
      .hbporch = 43,
      .vactive_video = 272,
      .vfporch = 2,
      .vsync = 1,
      .vbporch = 12,
   },
   /* 1 */
   { 
      .name = "480x240, ",
      .period = 120482,
      .hactive_video = 480,
      .hfporch = 20,
      .hsync = 1,
      .hbporch = 108,
      .vactive_video = 240,
      .vfporch = 2,
      .vsync = 1,
      .vbporch = 20,
   },
   /* 2 */
   { 
      .name = "640x480, 60 Hz",
      .period = 40000,
      .hactive_video = 640,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 48,
      .vactive_video = 480,
      .vfporch = 11,
      .vsync = 2,
      .vbporch = 31,
   },
   /* 3 */
   {
      .name =  "640x480, 72 Hz",
      .period = 31746,
      .hactive_video = 640,
      .hfporch = 24,
      .hsync = 40,
      .hbporch = 148,
      .vactive_video = 480,
      .vfporch = 9,
      .vsync = 3,
      .vbporch = 28,
   },
   /* 4 */
   {
      .name =  "640x480, 75 Hz",
      .period = 31746,
      .hactive_video = 640,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 48,
      .vactive_video = 480,
      .vfporch = 11,
      .vsync = 2,
      .vbporch = 32,
   },
   /* 5 */
   {
      .name =  "640x480, 85 Hz",
      .period = 27778,
      .hactive_video = 640,
      .hfporch = 32,
      .hsync = 48,
      .hbporch = 112,
      .vactive_video = 480,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 25,
   },
   /* 6 */
   { 
      .name = "800x480, ",
      .period = 30120,
      .hactive_video = 800,
      .hfporch = 40,
      .hsync = 1,
      .hbporch = 216,
      .vactive_video = 480,
      .vfporch = 10,
      .vsync = 1,
      .vbporch = 35,
   },
   /* 7 */
   {
      .name =  "800x600, 56 Hz",
      .period = 26247,
      .hactive_video = 800,
      .hfporch = 32,
      .hsync = 128,
      .hbporch = 128,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 4,
      .vbporch = 14,
   },
   /* 8 */
   {
      .name =  "800x600, 60 Hz",
      .period = 25000,
      .hactive_video = 800,
      .hfporch = 40,
      .hsync = 128,
      .hbporch = 88,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 4,
      .vbporch = 23,
   },
   /* 9 */
   {
      .name =  "800x600, 72 Hz",
      .period = 20000,
      .hactive_video = 800,
      .hfporch = 56,
      .hsync = 120,
      .hbporch = 64,
      .vactive_video = 600,
      .vfporch = 37,
      .vsync = 6,
      .vbporch = 23,
   },
   /* 10 */
   {
      .name =  "800x600, 75 Hz",
      .period = 20202,
      .hactive_video = 800,
      .hfporch = 16,
      .hsync = 80,
      .hbporch = 160,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 2,
      .vbporch = 21,
   },
   /* 11 */
   {
      .name =  "800x600, 85 Hz",
      .period = 17778,
      .hactive_video = 800,
      .hfporch = 32,
      .hsync = 64,
      .hbporch = 152,
      .vactive_video = 600,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 27,
   },
   /* 12 */
   {
      .name =   "1024x768, 60 Hz",
      .period = 15385,
      .hactive_video = 1024,
      .hfporch = 24,
      .hsync = 136,
      .hbporch = 160,
      .vactive_video = 768,
      .vfporch = 3,
      .vsync = 6,
      .vbporch = 29,
   },
   /* 13 */
   {
      .name =  "1024x768, 70 Hz",
      .period = 13333,
      .hactive_video = 1024,
      .hfporch = 24,
      .hsync = 136,
      .hbporch = 144,
      .vactive_video = 768,
      .vfporch = 3,
      .vsync = 6,
      .vbporch = 29,
   },
   /* 14 */
   {
      .name =  "1024x768, 75 Hz",
      .period = 12698,
      .hactive_video = 1024,
      .hfporch = 16,
      .hsync = 96,
      .hbporch = 176,
      .vactive_video = 768,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 28,
   },
   /* 15 */
   {
      .name =  "1024x768, 80 Hz",
      .period = 10582,
      .hactive_video = 1024,
      .hfporch = 48,
      .hsync = 96,
      .hbporch = 208,
      .vactive_video = 768,
      .vfporch = 1,
      .vsync = 3,
      .vbporch = 36,
   },
   /* 16 */
   {
      .name = "small", 
      .period = 40000,
      .hactive_video = 10,
      .hfporch = 1,
      .hsync = 1,
      .hbporch = 1,
      .vactive_video = 10,
      .vfporch = 1,
      .vsync = 1,
      .vbporch = 1, 
   }
};


inline void mode1(uint32_t *, uint32_t *);
inline void mode2(uint32_t *, uint32_t *);
inline void mode3(uint32_t *, uint32_t *);
inline void mode4(uint32_t *, uint32_t *);
inline void mode5(uint32_t *, uint32_t *);
inline void mode6(uint32_t *, uint32_t *);


uint32_t *svga_enable();
void svga_disable(uint32_t *);


#endif /* _FRAMELOOP_H_ */
