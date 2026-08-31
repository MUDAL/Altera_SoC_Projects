# Reference: https://bytes.usc.edu/cs104/wiki/makefile/

PROJECT=bin2bcd_soc

ALT_DEVICE_FAMILY ?= soc_cv_av
SOCEDS_ROOT ?= $(SOCEDS_DEST_ROOT)
HWLIBS_ROOT = $(SOCEDS_ROOT)/ip/altera/hps/altera_hps/hwlib
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -g -Wall -D$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -I$(HWLIBS_ROOT)/include/
LDFLAGS = -g -Wall
CC = $(CROSS_COMPILE)gcc
ARCH = arm

BUILD=bin

all: $(BUILD)/$(PROJECT)

$(BUILD)/$(PROJECT): $(BUILD)/$(PROJECT).o
	$(CC) $(LDFLAGS) $< -o $@

$(BUILD)/$(PROJECT).o: $(PROJECT).c build
	$(CC) $(CFLAGS) -c $< -o $@

build: create_header
	mkdir -p $(BUILD)

create_header:
	sopc-create-header-files ../build/$(PROJECT).sopcinfo --single hps_0.h --module hps_0

.PHONY: clean
clean:
	rm -rf $(BUILD) hps_0.h