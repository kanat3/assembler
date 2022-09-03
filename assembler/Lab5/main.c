#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "grey_filter.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb/stb_image_write.h"

int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        printf("Usage: program %s requires two parameters: input file and two output files", argv[0]);
        return 1;
    }

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
    int res_channels = 1;
    int res_size = width * height * res_channels;

    unsigned char *res_img = (unsigned char *)malloc(res_size);
    if (!res_img)
    {
        printf("Memory allocation error!\n");
        return 1;
    }

    clock_t start = clock();
    grey_filter(img, res_img, img_size);
    clock_t end = clock();
    double time = end - start;
    time /= CLOCKS_PER_SEC;
    printf("C Time: %lg\n", time);

    stbi_write_jpg(output_file, width, height, res_channels, res_img, 100);

    start = clock();

    grey_filter_asm(img, res_img, img_size);
    end = clock();
    time = end - start;
    time /= CLOCKS_PER_SEC;
    printf("ASM Time: %lg\n", time);

    stbi_write_jpg(output_file_asm, width, height, res_channels, res_img, 100);

    stbi_image_free(img);
    free(res_img);
    return 0;
}
