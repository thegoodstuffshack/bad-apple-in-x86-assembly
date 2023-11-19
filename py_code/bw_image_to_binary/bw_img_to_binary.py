import numpy
import cv2
import time

def binarize_image(src, dest):
    img = cv2.imread(src, 2)
    ret, bw_img = cv2.threshold(img, 0,255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    binary = numpy.where(bw_img == 255, 1, bw_img) 
    
    binary = binary.tobytes()
    
    with open(dest, 'w') as dest:
        for r in range(0, len(binary) - 1):
            dest.write(str(binary[r]))
        dest.write(str(binary[-1]))

    
start = time.time()

count = 6562
a = 1
while(a <= count):
    if a > 99:
        img = 'bad_apple_' + str(a) + '.png'
        frame = cv2.imread('resized-frames/'+ img, 2)
    
        
    
        a += 1
    else:
        img = 'bad_apple_0' + str(a) + '.png'
        file = 'resized-frames/'+ img
        frame = cv2.imread(file, 2)
    
        ret, bw_frame = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        bw = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
    
        cv2.imwrite('resized-bw-frames/' + img, bw_frame)
    
        a += 1
# binarize_image('bad_apple.png', 'bad_apple.txt')


end = time.time()
print(end-start)