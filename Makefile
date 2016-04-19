ifneq ($(OS),Windows_NT)
ifneq "$(HDMI2USB_ENV)" "1"
$(error "Please 'source scripts/setup-env.sh'")
endif
endif

# Turn off Python's hash randomization
export PYTHONHASHSEED=0

# Always use GCC
export CLANG=0

CPU ?= lm32

opsis_minisoc:
	rm -rf build
	./opsis_base.py --with-ethernet --nocompile-gateware --cpu-type $(CPU)
	cd firmware && make clean all
	./opsis_base.py --with-ethernet --cpu-type $(CPU)

opsis_video:
	rm -rf build
	./opsis_video.py --nocompile-gateware --cpu-type $(CPU)
	cd firmware && make clean all
	./opsis_video.py --cpu-type $(CPU)

opsis_hdmi2usb:
	rm -rf build
	./opsis_hdmi2usb.py --nocompile-gateware --cpu-type $(CPU)
	cd firmware && make clean all
	./opsis_hdmi2usb.py --cpu-type $(CPU)

opsis_sim:
	rm -rf build
	./opsis_sim.py --nocompile-gateware --with-ethernet --cpu-type $(CPU)
	cd firmware && make clean all
	./opsis_sim.py --with-ethernet --cpu-type $(CPU)

load:
	./load.py

firmware:
	cd firmware && make clean all

load-firmware:
	litex_term --kernel firmware/firmware.bin --kernel-adr 0x20000000 COM8

.PHONY: load firmware load-firmware
