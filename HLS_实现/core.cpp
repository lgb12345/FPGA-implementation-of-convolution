#include "core.h"

void doImgproc(hls::stream<uint_8_side_channel> &inStream, hls::stream<int_8_side_channel> &outStream, int kernel[KERNEL_DIM*KERNEL_DIM], int operation)
{
	#pragma HLS INTERFACE s_axilite port=kernel bundle=KERNEL_BUS
	#pragma HLS INTERFACE s_axilite port=operation bundle=CRTL_BUS
	#pragma HLS INTERFACE s_axilite port=return bundle=CRTL_BUS
	#pragma HLS INTERFACE axis port=inStream
	#pragma HLS INTERFACE axis port=inStream2
	#pragma HLS INTERFACE axis port=outStream
	//Define the line buffer and setting the internal dependency to false through program
	hls::LineBuffer<KERNEL_DIM, IMG_WIDTH_OR_COLS, unsigned char> lineBuff;  //Define the size of line buffer £¨3  of linebuffer which size of 240£©
	hls::Window<KERNEL_DIM,KERNEL_DIM,short> window;  //Define the size of the window

	//Index used to keep track of row, clo
	int idxCol = 0;
	int idxRow = 0;
	int pixConvolved = 0;
	//Calculate delay to fix line-buffer offset
	int waitTicks = (IMG_WIDTH_OR_COLS*(KERNEL_DIM-1)+KERNEL_DIM)/2;
	int countWait = 0;
	int sentPixels = 0;

	int_8_side_channel dataOutSideChannel;
	uint_8_side_channel currPixelSideChannel;

	//Iterate on all pixels for 320x240 image, the HLS PIPELINE improves the latency
	for(int idxPixel = 0; idxPixel < (IMG_WIDTH_OR_COLS*IMG_HEIGHT_OR_ROWS); idxPixel++) // Sweep all the pixels
	{
		#pragma HLS PIPELINE
		//Read and cache
		currPixelSideChannel = inStream.read();
		//Get the pixel data
		unsigned char pixelIn = currPixelSideChannel.data;

		//Put data on the Linebuffer
		lineBuff.shift_up(idxCol);
		lineBuff.insert_top(pixelIn,idxCol);

		//Put data on the window and multiply with kernel, in this case, only 9 times multiplication, finish one time of window x kernel
		for(int idxWinRow = 0; idxWinRow < KERNEL_DIM; idxWinRow++)
		{
			for (int idxWinCol = 0; idxWinCol < KERNEL_DIM; idxWinCol++)
			{
				//idxWinCol + pixConvolved, will slide the window ...
				short val = (short)lineBuff.getval(idxWinRow, idxWinCol+pixConvolved); //Get value at specific position

				//Multiply kernel by the sampling window
				val = (short)kernel[(idxWinRow*KERNEL_DIM) + idxWinCol]*val;  //Kernel x value in
				window.insert(val, idxWinRow, idxWinCol); //Save back to the corresponding position, now the window is the product of kernel and the same size (3 x 3 window)
			}
		}

		//Avoid calculate out of the image boundaries
		short valOutput = 0;
		if ((idxRow >= KERNEL_DIM-1) && (idxCol >= KERNEL_DIM-1)) // Once finish 9 times multiplication
		{
			switch (operation)
			{
			case 0:
			{
				//Convolution
				valOutput = sumWindow(&window); //Sum of 9 results
				valOutput = valOutput /8;
				//Avoid negative values
				if (valOutput <0)
					valOutput = 0;
				break;
			}
			}

			pixConvolved++;
		}

		//Calculate row and col index
		if (idxCol < IMG_WIDTH_OR_COLS-1)
		{
			idxCol++;// Switch to next pixel in the same line
		}
		else
		{
			//New line
			idxCol = 0;
			idxRow++;
			pixConvolved = 0;
		}

		/*
		 * Fix the line buffer delay, on a 320x240image with 3x3 kernel, the delay will be
		 * ((240*2) +3)/2 = 241
		 * So we wait for 241 ticks send the results than out more 241 zeros
		 */

		//Put data on output stream (side-channel(tlast) way...)
		 dataOutSideChannel.data = valOutput;
		 dataOutSideChannel.keep = currPixelSideChannel.keep;
		 dataOutSideChannel.strb = currPixelSideChannel.strb;
		 dataOutSideChannel.user = currPixelSideChannel.user;
		 dataOutSideChannel.last = currPixelSideChannel.last;
		 dataOutSideChannel.id = currPixelSideChannel.id;
		 dataOutSideChannel.dest = currPixelSideChannel.dest;

		 outStream.write(dataOutSideChannel);

	}

}


//Sum all values inside window (Already multiplied by the kernel)
short sumWindow(hls::Window<KERNEL_DIM, KERNEL_DIM,short>*window)
{
	short accumulator = 0;

	//Iterate on the window multiplying and accumulating the kernel and sampling window
	for (int idxRow = 0; idxRow < KERNEL_DIM; idxRow++)
	{
		for (int idxCol = 0; idxCol < KERNEL_DIM; idxCol++)
		{
			accumulator = accumulator + (short)window->getval(idxRow, idxCol);
		}
	}
	return accumulator;
}
