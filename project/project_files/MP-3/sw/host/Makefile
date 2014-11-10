CC=gcc
CCOPT=-O2

all: png2raw.h png2raw.c
	$(CC) -c png2raw.c
	$(CC) $(CCOPT) -o png2raw -lpng png2raw.o

clean:
	rm -rf *.o *~ png2raw