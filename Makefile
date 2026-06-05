obj-m += medion_kbd.o

all:
	rm -rf /tmp/intc816_driver
	mkdir -p /tmp/intc816_driver
	cp medion_kbd.c /tmp/intc816_driver/
	echo "obj-m += medion_kbd.o" > /tmp/intc816_driver/Makefile
	make -C /lib/modules/$(shell uname -r)/build M=/tmp/intc816_driver modules
	cp /tmp/intc816_driver/medion_kbd.ko .

clean:
	make -C /lib/modules/$(shell uname -r)/build M=/tmp/intc816_driver clean
	rm -rf /tmp/intc816_driver
