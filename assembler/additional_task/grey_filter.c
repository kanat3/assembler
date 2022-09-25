#include "grey_filter.h"
#include <stdio.h>
#include <string.h>

void grey_filter (unsigned char *img, unsigned char *res_img, int size, int r_width, int px_pointer1, int px_pointer2, int width) {
	unsigned char *p = img;
    unsigned char *pg = res_img;
    unsigned char t = 0;

    p = img;
    pg = res_img;
    while (p != img + px_pointer1) {
        pg += 3;
        p += 3;
    }
	while (p < img + px_pointer2 && p < img + size) {
		unsigned char* w = p;
    	for (p; p < w + r_width * 3 ; p += 3, pg += 3) {
			t = *(p) * 0.3;
			t += *(p + 1) * 0.59;
	        t += *(p + 2) * 0.11;
	        *pg = (int) (t);
	        *(pg + 1) = *pg;
	        *(pg + 2) = *pg;
    	}
    	p = p - r_width * 3 + width * 3;
    	pg = pg - r_width * 3 + width * 3;
	}
}

int photo_process(unsigned char *img, unsigned char *res_img, int size, int r_width, int px_pointer1, int px_pointer2,
												 int width, int r_width2, int px_pointer3, int px_pointer4)
{

/*************************/
//		worh with coords
// size = width * height * channels
// r_width - ширина прямоугольника 1
// px_pointer1 - указатель пикселя на правый нижний угол

	unsigned char *p = img;
    unsigned char *pg = res_img;
    unsigned char t = 0;

    for (unsigned char *p = img; p < img + size; p += 3)
    {
    	memcpy(pg, p, 3);
        pg += 3;
    }

    grey_filter(img, res_img, size, r_width, px_pointer1, px_pointer2, width);
    grey_filter(img, res_img, size, r_width2, px_pointer3, px_pointer4, width);

    return 0;
}

int photo_process_asm(unsigned char *img, unsigned char *res_img, int size, int r_width, int px_pointer1, int px_pointer2,
												 int width, int r_width2, int px_pointer3, int px_pointer4)
{

/*************************/
//		worh with coords
// size = width * height * channels
// r_width - ширина прямоугольника 1
// px_pointer1 - указатель пикселя на правый нижний угол

	unsigned char *p = img;
    unsigned char *pg = res_img;
    unsigned char t = 0;

    for (unsigned char *p = img; p < img + size; p += 3)
    {
    	memcpy(pg, p, 3);
        pg += 3;
    }
    grey_filter_asm(img, res_img, size, r_width, px_pointer1, px_pointer2, width);
    grey_filter_asm(img, res_img, size, r_width2, px_pointer3, px_pointer4, width);

    return 0;
}
