NAME=the_light_extra

all:
	nasm -o $(NAME) -D width=$(WIDTH) -D height=$(HEIGHT) -D entry=0x0000000000010029 elf$(BITS).s
	chmod +x $(NAME)
	wc -c $(NAME)
	mv $(NAME) ../$(NAME)_$(WIDTH)x$(HEIGHT)x$(BITS)
	chmod +x ../$(NAME)_$(WIDTH)x$(HEIGHT)x$(BITS)
