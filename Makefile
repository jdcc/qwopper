all: grabpixel.o link

grabpixel.o: grabpixel.c
	gcc -c grabpixel.c -I/usr/X11R6/include

link: grabpixel.o
	gcc grabpixel.o -L/usr/X11R6/lib -lX11 -lm -o grabpixel

clean: 
	rm grabpixel.o grabpixel
