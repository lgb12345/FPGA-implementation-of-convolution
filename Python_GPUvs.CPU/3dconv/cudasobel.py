import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import pylab
import numpy as np
import time
import pycuda.autoinit
import pycuda.driver as drv
from pycuda.compiler import SourceModule
import numba as nb
import cv2
import math
from numba import cuda
cuda.select_device(0)

def convertu8(num):
    if num > 255 or num < -255:
        return 255
    elif -255 <= num <= 255:
        if abs(num - int(num)) < 0.5:
            return np.uint8(abs(num))
        else:
            return np.uint8(abs(num)) + 1

@cuda.jit
def process_gpu(img,rows,cols):
    # tx = cuda.blockIdx.x*cuda.blockDim.x+cuda.threadIdx.x
    # ty = cuda.blockIdx.y*cuda.blockDim.y+cuda.threadIdx.y
    # if tx<rows and ty<cols:
    #
    #     color = img[tx,ty]*2.0+30
    #     if color>255:
    #         img[tx,ty]=255
    #     elif color<0:
    #         img[tx,ty]=0
    #     else:
    #         img[tx,ty]=color

    # image = np.zeros((rows, cols), np.uint8)

    for i in range(1, rows - 1):
        for j in range(1, cols - 1):
            i = cuda.blockIdx.x * cuda.blockDim.x + cuda.threadIdx.x
            j = cuda.blockIdx.y * cuda.blockDim.y + cuda.threadIdx.y
            y = int(img[i - 1, j + 1]) - int(img[i - 1, j - 1]) + 2 * (
                    int(img[i, j + 1]) - int(img[i, j - 1])) + int(img[i + 1, j + 1]) - int(
                img[i + 1, j - 1])
            x = int(img[i + 1, j - 1]) - int(img[i - 1, j - 1]) + 2 * (
                    int(img[i + 1, j]) - int(img[i - 1, j])) + int(img[i + 1, j + 1]) - int(
                img[i - 1, j + 1])
            # image[i, j] = convertu8(abs(x) * 0.5 + abs(y) * 0.5)

    # return image

#cpu function
def process_cpu(img):
    rows,cols,channels=img.shape
    for i in range(rows):
        for j in range(cols):
            for c in range(3):
                color=img[i,j][c]*2.0+30
                if color>255:
                    img[i,j][c]=255
                elif color<0:
                    img[i,j][c]=0
                else:
                    img[i,j][c]=color


def main_image_process():
    # Create an image.
    img = mpimg.imread('./img/dyt.jpg')
    rows, cols = img.shape
    # start_cpu = time.time()
    # process_cpu(img)
    end_cpu = time.time()
    # time_cpu = (end_cpu - start_cpu)
    # print("CPU process time: " + str(time_cpu))
    ##GPU function
    threadsperblock = (16, 16)
    blockspergrid_x = int(math.ceil(rows / threadsperblock[0]))
    blockspergrid_y = int(math.ceil(cols / threadsperblock[1]))
    blockspergrid = (blockspergrid_x, blockspergrid_y)
    start_gpu = time.time()
    dImg = cuda.to_device(img)
    cuda.synchronize()
    process_gpu[blockspergrid, threadsperblock](dImg, rows, cols)
    cuda.synchronize()
    end_gpu = time.time()
    dst_gpu = dImg.copy_to_host()
    time_gpu = (end_gpu - start_gpu)
    print("GPU process time: " + str(time_gpu))
    # save
    print("Done.")


if __name__ == "__main__":
    main_image_process()

