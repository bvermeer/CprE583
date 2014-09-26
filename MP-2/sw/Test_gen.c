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

void SetupNetwork();

int sockfd;
struct sockaddr_in my_addr;    /* my address information */
struct sockaddr_in their_addr; /* connector's address information */
struct sockaddr_in rv_addr;
struct hostent *he;
int numbytes;

int addr_len;
char buf[MAXBUFLEN] = {0};

int main(int argc, char *argv[])
{
                                                                       
  // Check number of args
  if (argc != 3) 
  {
    fprintf(stderr,"usage: send hostname filename\n");
    exit(1);
  }

  /* get the host info */
  if ((he=gethostbyname(argv[1])) == NULL) 
  { 
    herror("gethostbyname");
    exit(1);
  }

  // Set up UDP connection
  SetupNetwork();


  // Send packet to destination
  if ((numbytes=sendto(sockfd, argv[2], strlen(argv[2]), 0,
      (struct sockaddr *)&their_addr, sizeof(struct sockaddr))) == -1) 
     {
       perror("sendto");
       exit(1);
     }



  fprintf(stderr, "sent %d bytes\n",numbytes);


  // Wait for reply
  addr_len = sizeof(struct sockaddr);
  if ((numbytes=recvfrom(sockfd, buf, MAXBUFLEN, 0, \
      (struct sockaddr *)&rv_addr, &addr_len)) == -1)
  {
    perror("recvfrom");
    exit(1);
  }                    
   
  buf[numbytes] = '\0';  // Make sure string is terminated for printf 
  fprintf(stderr, "got %d bytes with content %s\n",numbytes, buf);


  close(sockfd);
  return 0;

}


void SetupNetwork()
{

  if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) 
  {
    perror("socket");
    exit(1);
  }

  // Set up socket information of Packet destination
  their_addr.sin_family = AF_INET;      /* host byte order */
  their_addr.sin_port = htons(MYPORT);  /* short, network byte order */
  their_addr.sin_addr = *((struct in_addr *)he->h_addr);
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

}
