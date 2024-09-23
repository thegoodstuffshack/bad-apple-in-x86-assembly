import time
import numpy
import array
import cv2

count = 6562 # number of frames
hRes = 80
vRes = 24
frameAlignment = 256
a = 1
binaryFileData = array.array('B')
zeroArray = [0] * int(frameAlignment - vRes*hRes/8 - 2)
main_start = time.time()

def binarize_image(img):
	binary = numpy.where(img == 255, 1, img) 

	binary = binary.tobytes()
	i = 0
	while i < hRes * vRes:
		lowerbyte = binary[i] * 128 + binary[i+1] * 64 + binary[i+2] * 32 + binary[i+3] * 16 + binary[i+4] * 8 + binary[i+5] * 4 + binary[i+6] * 2 + binary[i+7]
		i += 8
		upperbyte = binary[i] * 128 + binary[i+1] * 64 + binary[i+2] * 32 + binary[i+3] * 16 + binary[i+4] * 8 + binary[i+5] * 4 + binary[i+6] * 2 + binary[i+7]
		binaryFileData.append(upperbyte)
		binaryFileData.append(lowerbyte)
		i += 8

	b = array.array('B')
	c = a
	while c > 255: # c/16 > 15
		b.append(c % 256)
		c /= 256
	b.append(int(c % 256))
	if a < 256:
		b.append(0)
	binaryFileData.extend(b)


# Main Loop
while (a <= count):
	if a > 99:
		img = 'bad_apple_' + str(a) + '.png'
	elif a > 9:
		img = 'bad_apple_0' + str(a) + '.png'
	else:
		img = 'bad_apple_00' + str(a) + '.png'

	image = cv2.imread('../image_sequence/' + img, cv2.IMREAD_GRAYSCALE)
	resized = cv2.resize(image, (hRes, vRes))
	ret, bw_frame = cv2.threshold(resized, 130, 255, cv2.THRESH_BINARY)
	binarize_image(bw_frame)
	binaryFileData.extend(zeroArray)

	print('\rformatted frame: ' + str(a) + ' / ' + str(count), end='')
	a += 1

binaryFileData = binaryFileData.tobytes()
with open('../frames.data', 'wb') as file:
	file.write(binaryFileData)

print('\nTotal Time: ' + str(time.time()-main_start))