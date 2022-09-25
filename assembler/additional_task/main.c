#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "grey_filter.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

int get_int (int* x, int* y) {
    int err;
    printf("coord x and y: ");
    err = scanf("%d", x);
    if (err <= 0) {
        puts("Bad input\n");
        return -1;
    }
    err = scanf("%d", y);
    if (err <= 0) {
        puts("Bad input\n");
        return -1;
    }
}

int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        printf("Usage: program %s requires two parameters: input file and two output files", argv[0]);
        return 1;
    }

    int x1, y1, x2, y2, x3, y3, x4, y4;
    x1 = 200;
    y1 = 200;
    x2 = 600;
    y2 = 800;
    x3 = 900;
    y3 = 50;
    x4 = 1000;
    y4 = 990;

    const char* input_file = argv[1];
    const char* output_file = argv[2];
    const char* output_file_asm = argv[3];

    int width, height, channels;
    unsigned char *img = stbi_load(input_file, &width, &height, &channels, 0);
    if (!img)
    {
        printf("File %s can not be loaded!\n", argv[0]);
        return 1;
    }

    printf("Image uploaded:\nwidth: %dpx\nheight: %dpx\nchannels: %d\n", width, height, channels);

    if (channels != 3)
    {
        printf("The image is in the wrong format\n");
        stbi_image_free(img);
        return 1;
    }

    int img_size = width * height * channels;
    int res_channels = 3;
    int res_size = width * height * res_channels;

    unsigned char *res_img = (unsigned char *)malloc(res_size);
    if (!res_img)
    {
        printf("Memory allocation error!\n");
        return 1;
    }
/*******************************/
    int r_width = x2 - x1;
    int px_pointer1, px_pointer2;
    // в х1/у1 угол слева
    if (r_width < 0) {
        r_width = (-1)*r_width;
        int swap = x2;
        x2 = x1;
        x1 = swap; // в x1/y1 всегда будет левый угол
    } // ширина прямоугольника
    //if (x1 < x2) // ok
    if ((y2 - y1) < 0 ) {
        puts("yes");
        // дан левый нижний и правый верхний
        px_pointer1 = y1 * width *3 + x1 * 3 + r_width * 3; // тут правый нижний теперь
        px_pointer2 = y2 * width * 3 + x2 * 3 - r_width * 3; // левый верхний
    } else {
        px_pointer1 = y1 * width * 3 + x1 * 3; // пиксель по первой координате
        px_pointer2 = y2 * width * 3 + x2 * 3; // пиксель по второй координате
    }
    if (px_pointer1 > px_pointer2) {
        int swap = px_pointer2;
        px_pointer2 = px_pointer1;
        px_pointer1 = swap;
    }


    int r_width2 = x4 - x3;
    int px_pointer3, px_pointer4;
    // в х1/у1 угол слева
    if (r_width2 < 0) {
        r_width2 = (-1)*r_width2;
        int swap = x4;
        x4 = x3;
        x3 = swap; // в x3/y1 всегда будет левый угол
    } // ширина прямоугольника
    //if (x3 < x4) // ok
    if ((y4 - y3) < 0 ) {
        puts("yes");
        // дан левый нижний и правый верхний
        px_pointer3 = y3 * width *3 + x3 * 3 + r_width2 * 3; // тут правый нижний теперь
        px_pointer4 = y4 * width * 3 + x4 * 3 - r_width2 * 3; // левый верхний
    } else {
        px_pointer3 = y3 * width * 3 + x3 * 3; // пиксель по первой координате
        px_pointer4 = y4 * width * 3 + x4 * 3; // пиксель по второй координате
    }
    if (px_pointer3 > px_pointer4) {
        int swap = px_pointer4;
        px_pointer4 = px_pointer3;
        px_pointer3 = swap;
    }
/******************************/

    clock_t start = clock();
    photo_process(img, res_img, img_size, r_width, px_pointer1, px_pointer2, width, r_width2, px_pointer3, px_pointer4);
    clock_t end = clock();
    double time = end - start;
    time /= CLOCKS_PER_SEC;
    printf("C Time: %lg\n", time);

    stbi_write_jpg(output_file, width, height, res_channels, res_img, 100);
    start = clock();

    photo_process_asm(img, res_img, img_size, r_width, px_pointer1, px_pointer2, width, r_width2, px_pointer3, px_pointer4);
    end = clock();
    time = end - start;
    time /= CLOCKS_PER_SEC;
    printf("ASM Time: %lg\n", time);

    stbi_write_jpg(output_file_asm, width, height, res_channels, res_img, 100);

    stbi_image_free(img);
    free(res_img);

    return 0;
}
