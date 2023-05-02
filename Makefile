CROSS_COMPILE ?= arm-linux-gnueabihf-
TARGET ?= bsp
CC := $(CROSS_COMPILE)gcc
CFLAGS := -g -Wall -nostdlib
LD := $(CROSS_COMPILE)ld
OBJDUMP := $(CROSS_COMPILE)objdump
OBJCOPY := $(CROSS_COMPILE)objcopy

INCDIRS := imx6ul \
			bsp/clk \
			bsp/delay \
			bsp/led
SRCDIRS := project \
			bsp/clk \
			bsp/delay \
			bsp/led

INCLUDE := $(patsubst %, -I %, $(INCDIRS))
SFILES := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.S))
CFILES := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.c))

SFILENDIR := $(notdir $(SFILES))
CFILENDIR := $(notdir $(CFILES))

SOBJS := $(patsubst %, obj/%, $(SFILENDIR:.S=.o))
COBJS := $(patsubst %, obj/%, $(CFILENDIR:.c=.o))
OBJS := $(SOBJS) $(COBJS)

VPATH := $(SRCDIRS)

$(TARGET).bin : $(OBJS)
	$(LD) -Timx6ul.lds -o $(TARGET).elf $^
	$(OBJCOPY) -O binary -S $(TARGET).elf $@
	$(OBJDUMP) -D -m arm $(TARGET).elf > $(TARGET).dis

$(SOBJS) : obj/%.o : %.S
	$(CC) $(CFLAGS) -c -O2 $(INCLUDE) $< -o $@ 

$(COBJS) : obj/%.o : %.c
	$(CC) $(CFLAGS) -c -O2 $(INCLUDE) $< -o $@ 

.PHONY : clean
clean: 
	rm -rf $(TARGET).elf $(TARGET).dis $(TARGET).bin $(COBJS) $(SOBJS)
