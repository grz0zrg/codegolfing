NAME=Mmrnmhrm

all:
	nasm elf32.s -o $(NAME) -D width=$(WIDTH) -D height=$(HEIGHT) -D entry=0x0000000000010029
	wc -c $(NAME)
	mv $(NAME) ../$(NAME)_$(WIDTH)x$(HEIGHT)x$(BITS)
	chmod +x ../$(NAME)_$(WIDTH)x$(HEIGHT)x$(BITS)