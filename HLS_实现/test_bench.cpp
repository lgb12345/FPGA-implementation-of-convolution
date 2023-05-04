#include <stdio.h>
#include <hls_opencv.h>
#include "core.h"


//#include "testUtils.h"

//Blur
/*
  char kernel[KERNEL_DIM*KERNEL_DIM]=
  {
	1,2,1,
	2,3,2,
	1,2,1,
  };
*/

//impulse
/*	char kernel [KERNEL_DIM*KERNEL_DIM]=
	{
	 0,0,0,
	 0,1,0,
	 0,0,0,
	};
*/

//Sobel
int kernel [KERNEL_DIM*KERNEL_DIM]=
{
 -1,-2,-1,
 0,0,0,
 1,2,1,
};

//Edge
//char kernel[KERNEL_DIM*KERNEL_DIM]=
//{
//	-1,-1,-1,
//	-1,8,-1,
//	-1,-1,-1,
//};


//Use with morphological (Erode, dilate)
/*char kernel[KERNEL_DIM*KERNEL_DIM]
{
	1,1,1,
	1,1,1,
	1,1,1,
};
*/

//Image file path

char outImage[IMG_HEIGHT_OR_ROWS][IMG_WIDTH_OR_COLS];

//Define stream for input and output
hls::stream<uint_8_side_channel> inputStream;
hls::stream<int_8_side_channel> outputStream;

int main()
{
	//set path of images
	std::string path = "D:\\_HLS_code\\2D_Convolution_Vivado_HLS\\imgs\\";

	for (int i = 1; i < 9; i++)
	{
		std::string filename  = std::to_string(i);
		filename = filename + ".jpg";
		std::string inFilename = path + filename;

		//Read input image
		printf("Load image.");

		cv::Mat imageSrc;  //Create matrix
		imageSrc = cv::imread(inFilename);// Put image to the matrix

		//Convert to grayscale
		cv::cvtColor(imageSrc, imageSrc, CV_BGR2GRAY);
		printf("Image, Rows:%d Cols:%d\n", imageSrc.rows, imageSrc.cols);


		//OpenCV mat that point to a array (cv::Size(Width, Height))
		//Define matrix that output the image, parameters: size of image , saving classification CV_8UC1:3 channels 8 bits unsigned
		cv::Mat imgCvOut(cv::Size(imageSrc.cols, imageSrc.rows), CV_8UC1, outImage, cv::Mat::AUTO_STEP);


		//Populate the input stream with the image bytes
		for(int idxRows = 0; idxRows < imageSrc.rows; idxRows++)
		{
			for(int idxCols = 0; idxCols < imageSrc.cols; idxCols++)
			{
				uint_8_side_channel valIn;
				valIn.data = imageSrc.at<unsigned char>(idxRows, idxCols);// at: access a specific pixel
				valIn.keep = 1; valIn.strb = 1; valIn.user = 1; valIn.id = 0; valIn.dest = 0;
				inputStream << valIn; //Put the image into the stream
			}
		}


		//Do the convilution on the core (Third parameter choose operation 0(conv), 1(erode), 2(dilate))
		doImgproc(inputStream, outputStream, kernel, 0);


		//Take data from the output stream to our array outImage (pointed in opencv)
		for (int idxRows = 0; idxRows < imageSrc.rows; idxRows++)
		{
			for (int idxCols = 0; idxCols < imageSrc.cols; idxCols++)
			{
				int_8_side_channel valOut;
				outputStream.read(valOut); //Read out the output stream
				outImage[idxRows][idxCols] = valOut.data; //Save the output image to outImage which is imgCvOut
			}
		}
		std::string outFilename = "sobel_" + filename;
		outFilename = path + outFilename;
		imwrite(outFilename, imgCvOut);
	}

	return 0;
}
