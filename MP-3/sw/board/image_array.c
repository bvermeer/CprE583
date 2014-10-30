#include <stdio.h>

int main(int argc, char *argv[])
{
    if(argc != 3)
    {
        printf("Usage: image_array <raw image> <file name>\n");

        return -1;
    }

    FILE *ptr_image;
    FILE *ptr_file;

    ptr_image = fopen(argv[1], "rb");

    if(!ptr_image)
    {
        printf("Unable to open up image!\n");

        return -1;
    }

    ptr_file = fopen(argv[2], "w");

    if(!ptr_file)
    {
        printf("Unable to open up file!\n");

        return -1;
    }

   char str[] = "static uint32_t image = {";

   fwrite(str, 1, sizeof(str), ptr_file);

   int x = 0;
   int y = 0;

   for(y = 0; y < 480; y++)
   {
        for(x = 0; x < 640; x++);
        {
            fwrite(ptr_image, 2, 1, ptr_file);

            fwrite(", ", 2, 1, ptr
        }
   }

}
