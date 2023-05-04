from numba import cuda, float32
import numpy as np
import time
import math
import cv2
import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import pylab
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
def convolve(result,image):
    i, j = cuda.grid(2)
    image_rows, image_cols = image.shape
    result[i,j] = 0
    if (i <= image_rows) and (j <= image_cols):
        y = int(image[i - 1, j + 1]) - int(image[i - 1, j - 1]) + 2 * (int(image[i, j + 1]) - int(image[i, j - 1])) + int(image[i + 1, j + 1]) - int(image[i + 1, j - 1])
        x = int(image[i + 1, j - 1]) - int(image[i - 1, j - 1]) + 2 * (int(image[i + 1, j]) - int(image[i - 1, j])) + int(image[i + 1, j + 1]) - int(image[i - 1, j + 1])
    num = abs(x) * 0.5 + abs(y) * 0.5
    if num > 255 or num < -255:
        result[i, j] = 255
    elif -255 <= num <= 255:
        if abs(num - int(num)) < 0.5:
            result[i, j] = np.uint8(abs(num))
        else:
            result[i, j] = np.uint8(abs(num)) + 1

def main_convolve():
    dyt = mpimg.imread('./img/dyt.jpg')
    gg = mpimg.imread('./img/gg.jpg')
    yxmt = mpimg.imread('./img/yxmt.jpg')
    qglf = mpimg.imread('./img/qglf.jpg')
    wh = mpimg.imread('./img/wh.jpg')
    ctm = mpimg.imread('./img/ctm.jpg')
    plgd = mpimg.imread('./img/plgd.jpg')
    mkswv = mpimg.imread('./img/mksw.jpg')
    ddyt = cuda.to_device(dyt)
    dgg = cuda.to_device(gg)
    dyxmt = cuda.to_device(yxmt)
    dqglf = cuda.to_device(qglf)
    dwh = cuda.to_device(wh)
    dctm = cuda.to_device(ctm)
    dplgd = cuda.to_device(plgd)
    dmkswv = cuda.to_device(mkswv)

    resultdyt = cuda.to_device(dyt)
    resultdgg = cuda.to_device(gg)
    resultdyxmt = cuda.to_device(yxmt)
    resultdqglf = cuda.to_device(qglf)
    resultdwh = cuda.to_device(qglf)
    resultdctm = cuda.to_device(qglf)
    resultdplgd = cuda.to_device(qglf)
    reusltdmkswv = cuda.to_device(qglf)

    rows, cols = dyt.shape

    ##GPU function
    threadsperblock = (16, 16)
    blockspergrid_x = int(math.ceil(rows / threadsperblock[0]))
    blockspergrid_y = int(math.ceil(cols / threadsperblock[1]))
    blockspergrid = (blockspergrid_x, blockspergrid_y)
    cuda.synchronize()
    start_gpu = time.time()
    for i in range(300):
        convolve[blockspergrid, threadsperblock](resultdyt, ddyt)
        dytresult_gpu = resultdyt.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdgg, dgg)
        dggresult_gpu = resultdgg.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdyxmt, dyxmt)
        dyxmtresult_gpu = resultdyxmt.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdqglf, dqglf)
        dqglfresult_gpu = resultdqglf.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdwh, dwh)
        dwhresult_gpu = resultdwh.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdctm, dctm)
        dctmresult_gpu = resultdctm.copy_to_host()
        convolve[blockspergrid, threadsperblock](resultdplgd, dplgd)
        dplgdresult_gpu = resultdplgd.copy_to_host()
        convolve[blockspergrid, threadsperblock](reusltdmkswv, dmkswv)
        dmkswvresult_gpu = reusltdmkswv.copy_to_host()


    cuda.synchronize()
    end_gpu = time.time()

    time_gpu = (end_gpu - start_gpu)
    print("GPU process time: " + str(time_gpu))
    # save
    cv2.imwrite("dytsobel.png", dytresult_gpu)
    cv2.imwrite("ggsobel.png", dggresult_gpu)
    cv2.imwrite("yxmtsobel.png", dyxmtresult_gpu)
    cv2.imwrite("qglfsobel.png", dqglfresult_gpu)
    cv2.imwrite("whsobel.png", dwhresult_gpu)
    cv2.imwrite("ctmsobel.png", dctmresult_gpu)
    cv2.imwrite("plgdsobel.png", dplgdresult_gpu)
    cv2.imwrite("mkswvsobel.png", dmkswvresult_gpu)
    print("Done.")


if __name__ == "__main__":
    main_convolve()


