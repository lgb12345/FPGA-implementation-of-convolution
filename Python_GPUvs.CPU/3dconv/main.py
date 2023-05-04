import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import pylab
import numpy as np
import time

def convertu8(num):
    if num > 255 or num < -255:
        return 255
    elif -255 <= num <= 255:
        if abs(num - int(num)) < 0.5:
            return np.uint8(abs(num))
        else:
            return np.uint8(abs(num)) + 1

def sobel(img):
    row = img.shape[0]
    col = img.shape[1]
    image = np.zeros((row, col), np.uint8)

    for i in range(1, row - 1):
        for j in range(1, col - 1):
            y = int(img[i - 1, j + 1]) - int(img[i - 1, j - 1]) + 2 * (
                    int(img[i, j + 1]) - int(img[i, j - 1])) + int(img[i + 1, j + 1]) - int(
                img[i + 1, j - 1])
            x = int(img[i + 1, j - 1]) - int(img[i - 1, j - 1]) + 2 * (
                    int(img[i + 1, j]) - int(img[i - 1, j])) + int(img[i + 1, j + 1]) - int(
                img[i - 1, j + 1])
            image[i, j] = convertu8(abs(x) * 0.5 + abs(y) * 0.5)

    return image

def sobelall():
    s = time.time()
    sobeldyt = sobel(dyt)
    sobelgg = sobel(gg)
    sobelyxmt = sobel(yxmt)
    sobelqglf = sobel(qglf)
    sobelwh = sobel(wh)
    sobelctm = sobel(ctm)
    sobelplgd = sobel(plgd)
    sobelmkswv = sobel(mkswv)
    e = time.time()
    print(e - s)
    return sobeldyt,sobelgg,sobelyxmt,sobelqglf,sobelwh,sobelctm,sobelplgd,sobelmkswv

if __name__ == '__main__':
    dyt = mpimg.imread('./img/dyt.jpg')
    gg = mpimg.imread('./img/gg.jpg')
    yxmt = mpimg.imread('./img/yxmt.jpg')
    qglf = mpimg.imread('./img/qglf.jpg')
    wh = mpimg.imread('./img/wh.jpg')
    ctm = mpimg.imread('./img/ctm.jpg')
    plgd = mpimg.imread('./img/plgd.jpg')
    mkswv = mpimg.imread('./img/mksw.jpg')
    sobeldyt,sobelgg,sobelyxmt,sobelqglf,sobelwh,sobelctm,sobelplgd,sobelmkswv=sobelall()
    plt.imshow(dyt, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobeldyt, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(gg, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelgg, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(yxmt, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelyxmt, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(qglf, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelqglf, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(wh, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelwh, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(ctm, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelctm, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(plgd, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelplgd, cmap=plt.get_cmap('gray'))
    pylab.show()

    plt.imshow(mkswv, cmap=plt.get_cmap('gray'))
    pylab.show()
    plt.imshow(sobelmkswv, cmap=plt.get_cmap('gray'))
    pylab.show


