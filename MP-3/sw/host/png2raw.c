/*****************************************************************************
 * Joseph Zambreno
 * Department of Electrical and Computer Engineering
 * Iowa State University
 *****************************************************************************/

/*****************************************************************************
 * png2raw.c - loads a .png file and converts to a .raw file containing
 * 16-bit pixels, stored in 5-6-5 RGB format. 
 *
 *
 * NOTES:
 * 10/26/12 by JAZ::Design created.
 *****************************************************************************/

#include "png2raw.h"

uint8_t *data;
uint16_t tpixel, tpixel2, red, green, blue;
uint32_t width, height, bytespp;

int main(int argc, char** argv) {

  uint32_t y, x;
  char *outname;
  FILE *outfile;

  
  if(argc != 2) {
    raise_error(ERR_USAGE, 0);
  }

  data = pngRead(argv[1], &width, &height);
  
  printf("%s is a valid PNG image of height %d, width %d\n", argv[1], 
	 height, width);

  outname = (char *)malloc(strlen(argv[1])+5);
  strcpy(outname, argv[1]);
  strncat(outname, ".raw", 4);

  outfile = fopen(outname, "wb");

  for(y = 0; y < height; y++) {
    
    for(x = 0; x < width; x++) {
      red   = (uint16_t)data[bytespp*(y*width + x) + 0];
      green = (uint16_t)data[bytespp*(y*width + x) + 1];
      blue  = (uint16_t)data[bytespp*(y*width + x) + 2];
   
      tpixel = ((red / 8) << 11) & 0xF800;
      tpixel |= ((green / 4) << 5) & 0x07E0;
      tpixel |= ((blue / 8) << 0) & 0x001F;

      /* Fix for endianness problems. */
      tpixel2 = ((tpixel & 0x00FF) << 8);
      tpixel2 |= ((tpixel & 0xFF00) >> 8);

      fwrite(&tpixel2, 2, 1, outfile);
    }
  }
  
  fclose(outfile);
  free(outname);
  return 0;
}


/*****************************************************************************
 * Function: pngRead
 * Description: reads a PNG file and returns the results as a byte array
 *****************************************************************************/
uint8_t *pngRead(char *png_fname, uint32_t *width, uint32_t *height) {

  FILE *infile;
  uint8_t *pixels;
  uint32_t row_bytes;
  png_bytepp row_pointers;
  png_structp png_ptr;
  png_infop info_ptr;
  uint32_t sig_read = 0, i, j, twidth, theight;
  int32_t color_type, interlace_type;

  // Open up the file, and read the header information
  infile = fopen(png_fname, "rb");
  if (!infile) {
    raise_error(ERR_NOFILE1, png_fname);
  }

  /* Create and initialize the png_struct with the desired error handler
   * functions.  If you want to use the default stderr and longjump method,
   * you can supply NULL for the last three parameters.  We also supply the
   * the compiler header file version, so that we know if the application
   * was compiled with a compatible version of the library.
   */
  png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING,
				   NULL, NULL, NULL);
  if (png_ptr == NULL) {
    fclose(infile);
    raise_error(ERR_NOMEM, (char *)"png_create_read_struct");
  }

  /* Allocate/initialize the memory for image information.*/
  info_ptr = png_create_info_struct(png_ptr);
  if (info_ptr == NULL) {
    fclose(infile);
    png_destroy_read_struct(&png_ptr, (png_infopp)NULL, (png_infopp)NULL);
    raise_error(ERR_NOMEM, (char *)"png_create_info_struct");
  }


  /* Set error handling if you are using the setjmp/longjmp method
   * (this is the normal method of doing things with libpng).
   * REQUIRED unless you  set up your own error handlers in
   * the png_create_read_struct() earlier.
   */
  if (setjmp(png_jmpbuf(png_ptr))) {
    png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp)NULL);
    fclose(infile);
    raise_error(ERR_BADFILE1, png_fname);
  }


  /* Set up the output control if you are using standard C streams */
  png_init_io(png_ptr, infile);

  /* If we have already read some of the signature */
  png_set_sig_bytes(png_ptr, sig_read);


  /* If you have enough memory to read in the entire image at once, and
   * you need to specify only transforms that can be controlled
   * with one of the PNG_TRANSFORM_* bits (this presently excludes
   * dithering, filling, setting background, and doing gamma
   * adjustment), then you can read the entire image (including pixels)
   * into the info structure with this call
   * PNG_TRANSFORM_STRIP_16 | PNG_TRANSFORM_PACKING  forces 8 bit
   * PNG_TRANSFORM_EXPAND forces to expand a palette into RGB
   */
  png_read_png(png_ptr, info_ptr, PNG_TRANSFORM_STRIP_16 |
	       PNG_TRANSFORM_PACKING | PNG_TRANSFORM_EXPAND, (png_voidp)NULL);

  twidth = png_get_image_width(png_ptr, info_ptr);
  theight = png_get_image_height(png_ptr, info_ptr);
  row_bytes = png_get_rowbytes(png_ptr, info_ptr);
  bytespp = row_bytes / twidth;

  pixels = (uint8_t *)malloc(row_bytes * theight);
  if (pixels == NULL) {
    fclose(infile);
    png_destroy_read_struct(&png_ptr, (png_infopp)NULL, (png_infopp)NULL);
    raise_error(ERR_NOMEM, (char *)"pixels");
  }

  row_pointers = png_get_rows(png_ptr, info_ptr);

  /* Don't reorder the rows */
  for (i = 0; i < theight; i++) {
    //memcpy(pixels+row_bytes*(theight-1-i), row_pointers[i], row_bytes);
    memcpy(pixels+row_bytes*(i), row_pointers[i], row_bytes);
  }

  /* Clean up our data structures and leave */
  png_destroy_read_struct(&png_ptr, &info_ptr, (png_infopp)NULL);

  fclose(infile);

  *width = twidth;
  *height = theight;

  return pixels;

}


/*****************************************************************************
 * Function: raise_error
 * Description: Prints out an error message determined by
 * the condition and exits the program.
 *****************************************************************************/
void raise_error(uint32_t error_num, char *msg) {

  fprintf(stderr, "\n");
  switch(error_num) {
    case ERR_USAGE:
      fprintf(stderr, "Usage: %s file ", EXEC_NAME);
      break;
    case ERR_NOFILE1:
      fprintf(stderr, "Error: %s png file not found\n", msg);
      break;
    case ERR_NOFILE2:
      fprintf(stderr, "Error: %s output file cannot be opened\n", msg);
      break;
    case ERR_BADFILE1:
      fprintf(stderr, "Error: %s png file is invalid\n", msg);
      break;
    case ERR_BADFILE2:
      fprintf(stderr, "Error: %s file is invalid\n", msg);
      break;
    case ERR_NOMEM:
      fprintf(stderr, "Error: memory allocation problem in %s\n", msg);
      break;
    case ERR_UNDEFINED:
    default:
      fprintf(stderr, "Error: undefined error\n");
      break;
  }
  fprintf(stderr, "%s exited with error code %d\n", EXEC_NAME, error_num);

  exit(error_num);
}




