#include <stdio.h>   /* Standard input/output definitions */
#include <stdlib.h>  /* Standard libraries */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

//int open_port(void);
char convToNumb(char ch);
char convToChar(char ch);

int main()
{
  int fd = 0;
  int r = 0;
  int w = 0;
  //char ucmd[32];
  char ucmd[5];
  //char rdch[5];
  char rdch[32];
  struct termios options, oldtio;

  fd = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NDELAY); // opening up the serial port

  if (fd == -1)
  {
    printf("Error in opening up the port /dev/ttyS0\nExiting program...\n");
    close(fd);
    exit(1);
  }
  
  
  
  // setting up the port

  fcntl(fd, F_SETFL); 			        // FNDELAY option will cause the read function to return immediately if there is no data to be read
						// instead of stalling

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
    fgets(ucmd,32, stdin); 	// obtaining user's data

    if (ucmd[0]=='q')		// exit the program if you encounter a q
      break;

    ucmd[0] = convToNumb(ucmd[0]); // converting the number character to 

    w = write(fd, &ucmd[0], 1);	// otherwise, transmit the data
    if (w < 0)
      printf("write failed!\n");

    sleep(1); // this is an overshoot of wait time

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
