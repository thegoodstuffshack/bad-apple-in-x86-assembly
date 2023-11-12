import cv2
import time

count = 6562
a = 1
start = time.time()

while(a <= count):
    if a > 99:
        img = 'bad_apple_' + str(a) + '.png'
        frame = cv2.imread('resized-frames/'+ img, 2)
    
        ret, bw_frame = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        bw = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
    
        cv2.imwrite('resized-bw-frames/' + img, bw_frame)
    
        a += 1
    else:
        img = 'bad_apple_0' + str(a) + '.png'
        file = 'resized-frames/'+ img
        frame = cv2.imread(file, 2)
    
        ret, bw_frame = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
        bw = cv2.threshold(frame, 130, 255, cv2.THRESH_BINARY)
    
        cv2.imwrite('resized-bw-frames/' + img, bw_frame)
    
        a += 1
    
    

end = time.time()
print(end-start)

# cv2.imshow("Binary", bw_frame)  # make window
# cv2.waitKey(1000)     # wait x ms before closing
# cv2.destroyAllWindows() # kill window
