import cv2
import time
import numpy


def binarize_image(img, dest, a):
    ret, bw_img = cv2.threshold(img, 0,255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    binary = numpy.where(bw_img == 255, 1, bw_img) 
    
    binary = binary.tobytes()
    
    with open(dest, 'w') as dest:
        for r in range(0, len(binary) - 1):
            if r == 0:
                dest.write('dw ' + '\\' + '\n' )
                dest.write('0b')
            if r % 16 == 0 and r != 0:
                dest.write(', 0b')
            dest.write(str(binary[r]))
        dest.write(str(binary[-1]))
        dest.write('\ndw 0b' + bin(a)[2:].zfill(16))

count = 6562
a = 1
start = time.time()

while(a <= count):
    if a > 99:
        img = 'bad_apple_' + str(a) + '.png'
        frame = cv2.imread('py_code/resized-frames/'+ img, 2)
    
        ret, bw_frame = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        bw = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        binarize_image(bw_frame, 'data/bad_apple_' + str(a) + '.data', a)
        
        a += 1
    else:
        img = 'bad_apple_0' + str(a) + '.png'
        file = 'py_code/resized-frames/'+ img
        frame = cv2.imread(file, 2)
    
        ret, bw_frame = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        bw = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        binarize_image(bw_frame, 'data/bad_apple_0' + str(a) + '.data', a)
    
        a += 1
    
    

end = time.time()
print(end-start)