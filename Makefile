######################################################################################
# Copyright (c) 2015,  Vipin Bakshi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
######################################################################################

# GNU ARM Toolchain Setup
ARM_GCC_BIN = $(ARM_GCC_LOC)/bin
ARM_GCC_LIB = $(ARM_GCC_LOC)/arm_none_eabi/lib
ARM_GCC_INC = $(ARM_GCC_LOC)/arm_none_eabi/include
ARM_AS      = $(ARM_GCC_BIN)/arm-none-eabi-as
ARM_CC      = $(ARM_GCC_BIN)/arm-none-eabi-gcc
ARM_LD      = $(ARM_GCC_BIN)/arm-none-eabi-gcc
ARM_OBJCPY  = $(ARM_GCC_BIN)/arm-none-eabi-objcopy
ARM_SIZE    = $(ARM_GCC_BIN)/arm-none-eabi-size

# Platform Specific Commands
ifeq ($(OS),Windows_NT)
	RM 		= rd /s /q
	MV 		= ..\nrf51os\resources\GnuWin32\bin\mv.exe
	NRFJPROG	= nrfjprog
	ARM_GCC_LOC     = ..\nrf51os\resources/gcc-arm-none-eabi-4_9-2015q3-20150921-win32\gcc-arm-none-eabi-4_9-2015q3
else
	UNAME_S		= $(shell uname -s)
	UNAME_V		= $(shell uname -p)
	RM 	  	= rm -rf
	MV 	  	= mv

	ifeq ($(UNAME_S), Darwin)
		NRFJPROG    	= ../nrf51os/resources/nRF5x-CommandLineTools/nRF5x-Command-Line-Tools_8_4_0_OSX/nrfjprog/nrfjprog
		ARM_GCC_LOC     = ../nrf51os/resources/gcc-arm-none-eabi-4_9-2015q3-20150921-mac/gcc-arm-none-eabi-4_9-2015q3
	else
		ifeq ($(UNAME_V), x86_64)
			NRFJPROG    	= ../nrf51os/resources/nRF5x-CommandLineTools/nRF5x-Command-Line-Tools_8_4_0_Linux-x86_64/nrfjprog/nrfjprog
			ARM_GCC_LOC     = ../nrf51os/resources/gcc-arm-none-eabi-4_9-2015q3-20150921-linux/gcc-arm-none-eabi-4_9-2015q3
		else
			NRFJPROG    	= ../nrf51os/resources/nRF5x-CommandLineTools/nRF5x-Command-Line-Tools_8_4_0_Linux_i386/nrfjprog/nrfjprog
			ARM_GCC_LOC     = ../nrf51os/resources/gcc-arm-none-eabi-4_9-2015q3-20150921-linux/gcc-arm-none-eabi-4_9-2015q3
		endif
	endif
endif


# Source Collection
PRJ      = _mpgl1
INCS    += -I.
INCS    += -I./firmware_mpg_common/
INCS    += -I./firmware_mpg_common/application/
INCS    += -I./firmware_mpg_common/cmsis/
INCS    += -I./firmware_mpg_common/drivers/
INCS    += -I./firmware_mpgl1/
INCS    += -I./firmware_mpgl1/application/
INCS    += -I./firmware_mpgl1/bsp/
INCS    += -I./firmware_mpgl1/drivers/
SRCS    = $(notdir $(wildcard ./firmware_mpg_common/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpg_common/application/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpg_common/cmsis/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpg_common/drivers/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpgl1/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpgl1/application/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpgl1/bsp/*.c))
SRCS    += $(notdir $(wildcard ./firmware_mpgl1/drivers/*.c))
SRCS_AS += $(notdir $(wildcard ./firmware_mpg_common/*.s))
OBJS     = $(SRCS:.c=.o)
OBJS_AS  = $(SRCS_AS:.s=.o)
SRC_PTH    += ./
SRC_PTH    += ./firmware_mpg_common/
SRC_PTH    += ./firmware_mpg_common/application/
SRC_PTH    += ./firmware_mpg_common/cmsis/
SRC_PTH    += ./firmware_mpg_common/drivers/
SRC_PTH    += ./firmware_mpgl1/
SRC_PTH    += ./firmware_mpgl1/application/
SRC_PTH    += ./firmware_mpgl1/bsp/
SRC_PTH    += ./firmware_mpgl1/drivers/
SRC_PTH_AS += ./firmware_mpgl1_common/
L_COMMON    = ../nrf51os/resources/nRF51_SDK_9.0.0_2e23562/components/toolchain/gcc/
L_SCRIPT = ../nrf51os/resources/nRF51_SDK_9.0.0_2e23562/components/softdevice/s110/toolchain/armgcc/armgcc_s110_nrf51422_xxaa.ld


# Flags
CFLAGS   = -mcpu=cortex-m0 -mthumb -mabi=aapcs --std=gnu99 -Wall  -mfloat-abi=soft -ffunction-sections -fdata-sections -fno-strict-aliasing  -fno-builtin --short-enums
CFLAGS   += -DMPGL1 -DMPG1
AFLAGS   = -x assembler-with-cpp
LDFLAGS = -mcpu=cortex-m3 -mthumb -mabi=aapcs  -L$(L_COMMON) -T$(L_SCRIPT) -Xlinker -Map=$(PRJ)/$(PRJ).map  -Wl,--gc-sections  #-nostartfiles -nodefaultlibs -nostdlib

# Source Lookup Paths
vpath %.c $(SRC_PTH)
vpath %.s $(SRC_PTH_AS)


# Execution
all: clean  makedir echoer $(OBJS) $(OBJS_AS) moveobjects linkobjects elftohex printsize flash_app


echoer:
	@echo $(ARM_CC)

clean:
ifeq ($(OS),Windows_NT)
		del *.o
		rmdir /s /q $(PRJ)
else
		$(RM) ./*.o
		$(RM) $(PRJ)
endif
makedir:
	mkdir $(PRJ)

%.o:%.c   	
	$(ARM_CC) $(CFLAGS) $(INCS) -c -o  $@ $< 
	@echo $(SRCS)

%.o:%.s
	$(ARM_CC) $(AFLAGS) -c -o  $@ $< 
	@echo $(SRCS_AS)

moveobjects:
	$(MV) ./*.o ./$(PRJ)

linkobjects:
	$(ARM_LD) ./$(PRJ)/*.o  -o ./$(PRJ)/$(PRJ).elf $(LDFLAGS) 

elftohex:
	$(ARM_OBJCPY) -O ihex ./$(PRJ)/$(PRJ).elf ./$(PRJ)/$(PRJ).hex 

printsize:
	$(ARM_SIZE)	--format=SysV ./$(PRJ)/$(PRJ).elf

flash_app:
	@echo Flashing $(PRJ)/$(PRJ).hex
	$(NRFJPROG) --program $(PRJ)/$(PRJ).hex -f nrf51 --sectorerase --verify
	$(NRFJPROG) --reset
	$(NRFJPROG) --run

flash_sd:
	@echo Flashing s110_softdevice.hex
	$(NRFJPROG) --program ../resources/nRF51_SDK_9.0.0_2e23562/components/softdevice/s110/hex/s110_softdevice.hex --sectorerase --verify
