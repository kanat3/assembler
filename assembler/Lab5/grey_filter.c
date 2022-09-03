#include "grey_filter.h"

int grey_filter(unsigned char *img, unsigned char *res_img, int size)
{
    unsigned char *pg = res_img;
    for (unsigned char *p = img; p < img + size; p += 3)
    {
        unsigned char t = *p;
        t = *(p + 1) * 0.3;
        t += *(p + 2) * 0.59;
        t += *(p + 3) * 0.11;
        *pg = (int) (t);
        ++pg;
    }
    return 0;
}
