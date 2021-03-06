
PROJECT	= st_learning

## Cross-compilation commands 
CC      = arm-none-eabi-gcc
CXX	= arm-none-eabi-g++
LD      = arm-none-eabi-ld
AR      = arm-none-eabi-ar
AS      = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE    = arm-none-eabi-size

# Project target
CPU	= cortex-m4
MCU	= STM32F401xE

# Project structure
SRCDIR		= src
INCDIR		= include
BINDIR		= bin
OBJDIR		= obj
CMSIS_DIR	= cmsis
HALDIR		= hal
CMSIS_DEV_SRC	= $(CMSIS_DIR)/device/src
CMSIS_DEV_INC	= $(CMSIS_DIR)/device/include
CMSIS_INC	= $(CMSIS_DIR)/include
HAL_DIR		= hal
HAL_SRC		= $(HAL_DIR)/src
HAL_INC		= $(HAL_DIR)/include

# Linker script
LDDIR		= $(CMSIS_DIR)/linker
LDSCRIPT	= $(LDDIR)/STM32F401VEHx_FLASH.ld

# Core sources (user needs to select startup file and paste it to src
HAL_OBJ_SRC		= $(wildcard $(HAL_SRC)/*.c)
HAL_LIB_OBJS		= $(HAL_OBJ_SRC:.c=.o)
HAL_LOCAL_LIB_OBJS	= $(notdir $(HAL_LIB_OBJS))

# Program sources
OBJ_SRC		 = $(wildcard $(SRCDIR)/*.c) 
OBJ_ASM		 = $(wildcard $(SRCDIR)/*.s)
LOCAL_LIB_OBJS	 = $(notdir $(OBJ_SRC:.c=.o)) 
LOCAL_LIB_ASM	 = $(notdir $(OBJ_ASM:.s=.o))
LIB_OBJS	 = $(addprefix $(OBJDIR)/,$(LOCAL_LIB_OBJS))
LIB_OBJS	+= $(addprefix $(OBJDIR)/,$(LOCAL_LIB_ASM))

# Include paths
INC		= -I$(CMSIS_INC) -I$(HAL_INC) -I$(CMSIS_DEV_INC) -I$(INCDIR)

# Build Arguments
CFLAGS	= -std=c99 -Wall -fno-common -mthumb -mcpu=$(CPU) -DSTM32F401xE --specs=nosys.specs -g -Wa,-ahlms=$(addprefix $(OBJDIR)/,$(notdir $(<:.c=.lst)))
CFLAGS		+= $(INC)
ASFLAGS		 = -mcpu=$(CPU)
LFLAGS		 = -T$(LDSCRIPT) -mthumb -mcpu=$(CPU) --specs=nano.specs --specs=nosys.specs -Wl,--gc-sections

RM	= rm -rf

# Targets

all:: $(BINDIR)/$(PROJECT).bin $(BINDIR)/$(PROJECT).hex 

$(BINDIR)/$(PROJECT).bin: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -R .stack --strip-unneeded -O binary $< $@

$(BINDIR)/$(PROJECT).hex: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -O ihex $< $@

$(BINDIR)/$(PROJECT).elf: $(LIB_OBJS) $(OBJDIR)/hal.a 
	@echo "Creating $(PROJECT).elf"
	@mkdir -p $(dir $@)
	$(CC)  $^ $(LFLAGS) -o $(BINDIR)/$(PROJECT).elf
	$(OBJDUMP) -D $(BINDIR)/$(PROJECT).elf > $(BINDIR)/$(PROJECT).lst
	$(SIZE) $(BINDIR)/$(PROJECT).elf

$(OBJDIR)/hal.a: $(HAL_OBJ_SRC)
	@echo "Creating core lib (hal.a)"
	@mkdir -p $(dir $@)
	$(CC) $(HAL_OBJ_SRC) $(CFLAGS) -c 
	$(AR) rcs $@ $(HAL_LOCAL_LIB_OBJS)
	@rm -f $(HAL_LOCAL_LIB_OBJS)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@echo "Compiling c source files in src"
	@mkdir -p $(dir $@)
	$(CC) -c -o $@ $< $(CFLAGS)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@echo "Compiling asm files in src"
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	@rm -rf $(OBJDIR)/*.o
	@rm -f  $(HAL_LOCAL_LIB_OBJS)

cleanall:
	@rm -rf $(OBJDIR)/*
	@rm -f  $(HAL_LOCAL_LIB_OBJS)

flash: $(BINDIR)/$(PROJECT).bin
	@st-flash write $(BINDIR)/$(PROJECT).bin 0x08000000
