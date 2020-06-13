#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
.SECONDARY:

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/ds_rules

export VERSION_MAJOR	:= 0
export VERSION_MINOR	:= 0
export VERSION_PATCH	:= 0

VERSION	:=	$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
TARGET		:=	$(SELECTED_FOLDER)_folder
BUILD		:=	build_$(SELECTED_FOLDER)
SOURCES		:=	source
INCLUDES	:=	include
NDSTOOL_G	:=	$(SELECTED_FOLDER)

ifeq ($(NDSTOOL_G), \#)
	NDSTOOL_G := 0
endif

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
ARCH	:=	-mthumb -mthumb-interwork

CFLAGS	:=	-g -Wall -O2 \
		-ffunction-sections -fdata-sections \
 		-march=armv5te -mtune=arm946e-s -fomit-frame-pointer\
		-ffast-math \
		$(ARCH)

CFLAGS	+=	$(INCLUDE) -DARM9
CXXFLAGS	:= $(CFLAGS) -fno-rtti -fno-exceptions -std=c++11

ASFLAGS	:=	-g $(ARCH)
LDFLAGS	=	-specs=ds_arm9.specs -g -Wl,--gc-sections $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS	:= 	-lfat -lnds9
LIBDIRS	:=	$(LIBNDS)
 
#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------
export TOPDIR	:=	$(CURDIR)

export OUTPUT	:=	$(CURDIR)/$(TARGET)

export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

ifneq ($(strip $(NITRODATA)),)
	export NITRO_FILES	:=	$(CURDIR)/$(NITRODATA)
endif

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
BMPFILES	:=	$(foreach dir,$(GRAPHICS),$(notdir $(wildcard $(dir)/*.bmp)))
BINFILES	:=	load.bin bootstub.bin
 
#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
#---------------------------------------------------------------------------------
	export LD	:=	$(CC)
#---------------------------------------------------------------------------------
else
#---------------------------------------------------------------------------------
	export LD	:=	$(CXX)
#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------

export OFILES	:=	$(addsuffix .o,$(BINFILES)) \
					$(CPPFILES:.cpp=.o) $(CFILES:.c=.o)
 
export INCLUDE	:=	$(foreach dir,$(INCLUDES),-iquote $(CURDIR)/$(dir)) \
					$(foreach dir,$(LIBDIRS),-I$(dir)/include) \
					-I$(CURDIR)/$(BUILD)
 
export LIBPATHS	:=	$(foreach dir,$(LIBDIRS),-L$(dir)/lib)

export GAME_TITLE := $(SELECTED_FOLDER) folder

.PHONY: bootloader bootstub clean arm7/$(TARGET).elf arm9/$(TARGET).elf

all:	bootloader bootstub $(TARGET).nds
	
$(TARGET).nds:	$(TARGET).arm7 $(TARGET).arm9
	ndstool	-c "$(TARGET).nds" -7 "arm7.elf" -9 "$(TARGET).arm9.elf" \
			-b "icons/$(SELECTED_FOLDER).bmp" "$(GAME_TITLE);Nintendo 3DS folder selector" \
			-g H3F$(NDSTOOL_G) 01 "$(GAME_TITLE)" -z 80040000 -u 00030004
	python patch_ndsheader_dsiware_twltouch.py $(CURDIR)/"$(TARGET).nds"
	./make_cia --srl="$(TARGET).nds"

$(TARGET).arm7: arm7/$(TARGET).elf
	cp "arm7/arm7.elf" "arm7.elf"

$(TARGET).arm9: arm9/$(TARGET).elf
	cp "arm9/$(TARGET).elf" "$(TARGET).arm9.elf"

#---------------------------------------------------------------------------------
arm7/$(TARGET).elf:
	@$(MAKE) -C arm7
	
#---------------------------------------------------------------------------------
arm9/$(TARGET).elf:
	@$(MAKE) -C arm9 SELECTED_FOLDER=$(SELECTED_FOLDER)

#---------------------------------------------------------------------------------
clean:
	@echo clean ...
	@rm -fr $(BUILD) "$(TARGET).elf" "$(TARGET).nds" "$(TARGET).nds.orig.nds"
	@rm -fr "arm7.elf"
	@rm -fr "$(TARGET).arm9.elf"
	@$(MAKE) -C arm9 clean SELECTED_FOLDER=$(SELECTED_FOLDER)
	@$(MAKE) -C arm7 clean

data:
	@mkdir -p data

#---------------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------------
