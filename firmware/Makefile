include ../include/generated/variables.mak
include $(SOC_DIRECTORY)/software/common.mak

ifeq ($(PLATFORM),)
$(error PLATFORM not defined.)
endif
UPLATFORM = $(shell echo $(PLATFORM) | tr a-z A-Z)

ifeq ($(TARGET),)
$(error TARGET not defined.)
endif
UTARGET = $(shell echo $(TARGET) | tr a-z A-Z)

CFLAGS += -DPLATFORM_$(UPLATFORM) -DTARGET_$(UTARGET)

BUILD_DIRECTORY=$(BUILDINC_DIRECTORY)/../../

OBJECTS=\
	ci.o \
	config.o \
	edid.o \
	encoder.o \
	etherbone.o \
	ethernet.o \
	fx2.o \
	hdmi_in0.o \
	hdmi_in1.o \
	hdmi_out0.o \
	hdmi_out1.o \
	i2c.o \
	isr.o \
	main.o \
	mdio.o \
	opsis_eeprom.o \
	pattern.o \
	pll.o \
	processor.o \
	stdio_wrap.o \
	telnet.o \
	tofe_eeprom.o \
	version.o \
	version_data.o \
	uptime.o \


CFLAGS += \
	-I. \
	-I$(LIBUIP_DIRECTORY)/../uip \
	-I$(LIBUIP_DIRECTORY)

all: firmware.bin firmware.fbi

%.fbi: %.bin
	$(PYTHON) -m litex.soc.tools.mkmscimg -f $< -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@
	chmod -x $@
	$(PYTHON) -m litex.soc.tools.mkmscimg $<

firmware.elf: $(FIRMWARE_DIRECTORY)/linker.ld $(OBJECTS)

%.elf:
	$(LD) $(LDFLAGS) \
		-T $(FIRMWARE_DIRECTORY)/linker.ld \
		-N -o $@ \
                ../libbase/crt0-$(CPU).o \
                $(OBJECTS) \
                -L../libnet \
                -L../libbase \
                -L../libcompiler_rt \
		-L../libuip \
		-lbase-nofloat -luip -lcompiler_rt
	chmod -x $@

# pull in dependency info for *existing* .o files
-include $(OBJECTS:.o=.d)

%.o: $(FIRMWARE_DIRECTORY)/%.c
	$(compile)

%.o: $(FIRMWARE_DIRECTORY)/%.S
	$(assemble)

clean:
	$(RM) $(OBJECTS) $(OBJECTS:.o=.d) firmware.elf firmware.bin .*~ *~

pattern.o: version_data.h version_data.c
version.o: version_data.h version_data.c

version_data.h: version_data
version_data.c: version_data
version_data:
	bash $(FIRMWARE_DIRECTORY)/version_data.sh

.PHONY: all clean libs version_data
