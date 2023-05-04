#include "hls_video.h"
#include <iostream>
#include <string>

//Defination of size of image
#define IMG_WIDTH_OR_COLS 256
#define IMG_HEIGHT_OR_ROWS 256

// 3x3 kernel
#define KERNEL_DIM 3

//Image file path


//Use the axi stream side-channel
#include <ap_axi_sdata.h>
typedef ap_axiu<8,2,5,6> uint_8_side_channel;
typedef ap_axis<8,2,5,6> int_8_side_channel;

//Reference functions
short convolve2d(hls::Window<KERNEL_DIM,KERNEL_DIM,char>*window, char kernel[KERNEL_DIM*KERNEL_DIM]);


//IP
void doImgproc(hls::stream<uint_8_side_channel> &inStream, hls::stream<int_8_side_channel> &outStream, int kernel[KERNEL_DIM*KERNEL_DIM],int operation);
//Parameters: 1. Input stream 2. Output stream 3. Kernel 4. Operation


short sumWindow(hls::Window<KERNEL_DIM,KERNEL_DIM,short>*window);
