APP=hello
CC=sparc-elf-gcc
CCOPT=-msoft-float -O1


%.o: %.c
	$(CC) $(CCOPT) -c $<

all: frameloop hello 

hello: hello.o report_device.o
	$(CC) $(CCOPT) -o hello.leon hello.o report_device.o

frameloop:  frameloop.o report_device.o
	$(CC) $(CCOPT) -o frameloop.leon frameloop.o report_device.o

prom: $(APP)
	sparc-elf-objcopy -O srec $(APP).leon sram.srec
	sparc-elf-objcopy -O srec $(APP).leon sdram.srec
	cp sram.srec $(CDIR)/hw/designs/leon3-xilinx-ml509/
	cp sdram.srec $(CDIR)/hw/designs/leon3-xilinx-ml509/

clean:
	rm -rf *.exe *.leon *.o *.srec *~
