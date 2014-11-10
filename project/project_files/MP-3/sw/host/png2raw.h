/*****************************************************************************
 * Joseph Zambreno
 * Department of Electrical and Computer Engineering
 * Iowa State University
 *****************************************************************************/


/*****************************************************************************
 * png2raw.h - converts a png file to a .raw byte file, with 16-bit pixels
 * in 5-6-5 format. 
 *
 *
 * NOTES:
 * 10/26/12 by JAZ::Design created.
 *****************************************************************************/



#ifndef _PNG2RAW_H_
#define _PNG2RAW_H_


#include <png.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define EXEC_NAME "png2raw"

#define ERR_USAGE 1
#define ERR_NOFILE1 2
#define ERR_NOFILE2 3
#define ERR_BADFILE1 4
#define ERR_BADFILE2 5
#define ERR_NOMEM 50
#define ERR_UNDEFINED 100



/* Function prototypes (png2raw.c) */
uint8_t *pngRead(char *png_fname, uint32_t *width, uint32_t *height);
void raise_error(uint32_t error_num, char *msg);

#endif /* _PNG2RAW_H_ */
