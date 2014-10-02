#include <stdio.h> 
#include <stdlib.h> 
#include <errno.h> 
#include <string.h> 
#include <sys/types.h> 
#include <netinet/in.h> 
#include <netdb.h> 
#include <sys/socket.h> 
#include <sys/wait.h> 

#define MYPORT 0xAE22    /* This port will be used for Sending and reciving */
#define MAXBUFLEN 2000

int main(int argc, char *argv[])
{
int sockfd;
struct sockaddr_in my_addr;    /* my address information */
struct sockaddr_in their_addr; /* connector's address information */
struct hostent *he;
int numbytes;

int addr_len;
char buf[MAXBUFLEN];


// Do not need command line for echo program
//  if (argc != 3) 
//  {
//    fprintf(stderr,"usage: send hostname message\n");
//    exit(1);
//  }

  /* get the host info */
//  if ((he=gethostbyname(argv[1])) == NULL) 
//  { 
//    herror("gethostbyname");
//    exit(1);
//  }

  if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) 
  {
    perror("socket");
    exit(1);
  }

  // Set up socket information of Packet destination
  their_addr.sin_family = AF_INET;      /* host byte order */
  their_addr.sin_port = htons(MYPORT);  /* short, network byte order */
  // their_addr.sin_addr = *((struct in_addr *)he->h_addr);
  bzero(&(their_addr.sin_zero), 8);     /* zero the rest of the struct */


  // Set up socket informaion of Packet source
  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(MYPORT);     /* short, network byte order */
  my_addr.sin_addr.s_addr = INADDR_ANY; /* auto-fill with my IP */
  bzero(&(my_addr.sin_zero), 8);        /* zero the rest of the struct */

  // Bind port MYPORT to this program 
  // Lets OS know to route MYPORT packets to me
  if(bind(sockfd, (struct sockaddr *)&my_addr,
          sizeof(struct sockaddr))== -1)
  {
    perror("bind");
    exit(1);
  }


  // Wait for a packet
  addr_len = sizeof(struct sockaddr);
  if ((numbytes=recvfrom(sockfd, buf, MAXBUFLEN, 0, \
      (struct sockaddr *)&their_addr, &addr_len)) == -1)
  {
    perror("recvfrom");
    exit(1);
  }
                                                                                       
  printf("got %d byes\n",numbytes);

  // Add some info to the packet
  buf[numbytes] = ' ';
  buf[numbytes + 1] = 'O';
  buf[numbytes + 2] = 'k';
  buf[numbytes + 3] = '\0';


  // Send packet to destination
  if ((numbytes=sendto(sockfd, buf, (numbytes + 4), 0,
      (struct sockaddr *)&their_addr, sizeof(struct sockaddr))) == -1) 
     {
       perror("sendto");
       exit(1);
     }


  printf("sent %d bytes\n",(numbytes +4));


  close(sockfd);
  return 0;

}
