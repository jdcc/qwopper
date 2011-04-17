#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

void FindPixel (char *windowName, int x, int y, Display *display, Window rootWindow)
{
	Window parent;
	Window *children;
	Window *child;
	XImage *image;
	XWindowAttributes winAttr;
	XColor color;
	XTextProperty wmName;

	unsigned int noOfChildren;
	unsigned long pixel;
	int status;
	int i, red, green, blue;
	char **list;

	status = XGetWMName (display, rootWindow, &wmName);

	if ((status) && (wmName.value) && (wmName.nitems)) {
		if (strcmp(windowName, wmName.value) == 0) {
			XGetWindowAttributes(display, rootWindow, &winAttr);
			image = XGetImage(display, rootWindow, 0, 0, winAttr.width, winAttr.height, XAllPlanes(), ZPixmap);
			color.pixel = XGetPixel(image, x, y);
			XQueryColor(display, XDefaultColormap(display, XDefaultScreen(display)), &color);
			red = floor(color.red * 0.003891051);
			green = floor(color.green * 0.003891051);
			blue = floor(color.blue * 0.003891051);

			printf("%i %i %i\n", red, green, blue);
		}
	}
	
	
	status = XQueryTree (display, rootWindow, &rootWindow, &parent, &children, &noOfChildren);
	
	for (i=0; i < noOfChildren; i++) {
		FindPixel (windowName, x, y, display, children[i]);
	}
	
	XFree ((char*) children);
}
// END ENUMERATE WINDOWS

int main(int argc, char *argv[])
{
	if (argc != 4) {
		printf("Usage: %s \"Window Name\" <x> <y>\n", argv[0]);
		exit(0);
	}

	// CONNECT TO THE XSERVER
	Display *display;
	int depth;
	int screen;
	int connection;
	char *windowName = argv[1];
	int x = atoi(argv[2]);
	int y = atoi(argv[3]);
	Window window;

	display = XOpenDisplay (NULL);
	screen = DefaultScreen (display);
	depth = DefaultDepth (display, screen);
	connection = ConnectionNumber (display);
	
	// RETRIEVE ROOT WINDOW
	Window rootWindow;
	
	rootWindow = RootWindow (display, screen);	
	// END RETRIEVE ROOT WINDOW
	
	// LOOP THROUGH ALL WINDOWS
	FindPixel (windowName, x, y, display, rootWindow);
	// END LOOP THROUGH ALL WINDOWS
	
	// DISCONNECT FROM THE XSERVER
	XCloseDisplay (display);
	// END DISCONNECT FROM THE XSERVER

	return EXIT_SUCCESS;
}
