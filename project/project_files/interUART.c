#include <stdio.h>   /* Standard input/output definitions */
#include <stdlib.h>  /* Standard libraries */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

/* Range of seed: 0 to 65535*/

//int open_port(void);
char convToNumb(char ch);
char convToChar(char ch);

int main()
{
  int fd = 0;				// file descriptor for UART
  int r = 0;				// number of bytes read from the UART
  int w = 0;				// number of bytes written to the UART
  char ucmd[6];				// allowing only a character long input.
  char rdch[32]; 			// will decide the size of rdch soon
  struct termios options, oldtio; 	// necessary structures for UART setup

  fd = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NDELAY); // opening up the serial port

  if (fd == -1)
  {
    printf("Error in opening up the port /dev/ttyS0\nExiting program...\n");
    close(fd);
    exit(1);
  }
  
  // setting up the port

  fcntl(fd, F_SETFL, 0); 			// FNDELAY option will cause the read function to return immediately if there is no data to be read
						// instead of stalling (NOT SURE WHY THIS IS NOT WORKING WITH THE FNDELAY OPTION SET OFF)

  tcgetattr(fd, &oldtio);			// saving the default settings of the port
  tcgetattr(fd, &options);			// getting the current settings of the port

  cfsetispeed(&options, B9600);			// setting the input baud rate
  cfsetospeed(&options, B9600);			// setting the output baud rate

  options.c_cflag |= (CLOCAL | CREAD);		// setting local mode and enabling receiver mode

  options.c_cflag &= ~PARENB; 			// setting 8N1 mode
  options.c_cflag &= ~CSTOPB;
  options.c_cflag &= ~CSIZE;
  options.c_cflag |=  CS8;
                  
  options.c_cflag &= ~CRTSCTS;			// disabling hardware flow control  
 
  options.c_lflag &= ~(ICANON | ECHO | ISIG);	// setting raw input mode instead of canonical mode

  tcsetattr(fd, TCSANOW, &options);		// writing new settings for the port


  while (1)
  {

    printf("> "); 		// command prompt
    fgets(ucmd, 6, stdin); 	// obtaining user's data (6 because NULL is automatically appended at the end. This way we can read 5 characters)

    if (ucmd[0]=='q')		// exit the program if you encounter a q
      break;

    if (ucmd[0] >= '0' && ucmd[0] <= '9')
    {  //user entered a number with it being a 5-digit number at the max
	short i; // loop control variable
  	unsigned short num; // corresponding number of a character
	unsigned short finNum; // final number corresponding to the user's input
	unsigned short unit = 10000; // number to multiply the number by
	 
	for (i = 0; i < 5; i++) // 5 = sizeof(ucmd) - 1 because the seed will be 5 characters long and ucmd[5] will be a NULL
	{
	  if ( ucmd[i] == '\n')
	  {
	    finNum = finNum / (unit*10); // if the user entered less than 5 digits, then extracting the right number
	    break;
	  }
	  num = convToNumb(ucmd[i]); // extracting the number from user's input
	  finNum = finNum + num*unit; // adding the extracted number to the final number at the right place
	  unit = unit/10; // scaling unit for next number to be added
	}

	unsigned char  chOne = ( char ) ( finNum & 0x00FF );
	unsigned char  chTwo = ( char ) ( ( finNum & 0xFF00 ) >> 8 );	
 	
	write(fd, &chOne, 1);
	usleep(100);		// NOT SURE IF THIS IS NECESSARY
	write(fd, &chTwo, 1);
    }
      else
    {  // user entered a character
       w = write(fd, &ucmd[0], 1);
    }

    if (w < 0)
      printf("write failed!\n");

    //sleep(1); // this is an overshoot of wait time

// NEED TO WORK ON READING PART AFTER CONFIGURING THE HARDWARE TO BE ABLE TO SEND TWO CONSECUTIVE BYTES

    r = read(fd, &rdch, sizeof(rdch));	// read data after transmitting
    if ( r < 0 )
      printf("read failed!\n");
    else
      if ( r > 0 )
      {
        rdch[0] = convToChar(rdch[0]);
        printf("%d chars read: %c\n", r, rdch[0]);
      }

  }
  
  tcsetattr(fd, TCSANOW, &oldtio);
  close(fd);
  return 0;
}

/* Converting number character to its actual number 
	ch : character 48-57
*/
char convToNumb(char ch)
{
  return ch - 48;
}

/* Converting actual number to its number character
	ch : character 0-9
*/
char convToChar(char ch)
{
  return ch + 48;
}
