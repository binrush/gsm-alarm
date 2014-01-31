includes = 1-wire.asm alarm.asm crc8.asm defs.asm key.asm led.asm message.asm timers.asm usart.asm wait.asm
avra = /home/rush/avr/avra-1.3.0-linux-i386-static
f_cpu = 12000000

all: hex upload

hex: $(includes) main.asm
	$(avra)/avra -I $(avra)/includes/ -D F_CPU=$(f_cpu) main.asm

upload: main.hex
	echo -e '::erase\n::reset\n' | dd of=$(programmer)
	dd if=main.hex of=$(programmer)
