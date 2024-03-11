import time
import numpy
import cv2

count = 6562 # number of frames
a = 1
main_start = time.time()

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
  
def generate_asm_include(dest):
	a = 1
	b = 3
	outfile = open(dest, 'w')

	while (a <= count):
		if a > 99:
			include = '\n%include "data/bad_apple_' + str(a) + '.data"\n'	
		elif a > 9:
			include = '\n%include "data/bad_apple_0' + str(a) + '.data"\n'
		else:
			include = '\n%include "data/bad_apple_00' + str(a) + '.data"\n'

		buffer = 'times ' +str(b) + ' * 256 - ($-$$) db 0'
		addition = include + buffer
		outfile.write(str(addition))
		a += 1
		b += 1


src_dir = '../src/'
generate_asm_include(src_dir + 'frames.asm')

# Main Loop
while (a <= count):
	if a > 99:
		img = 'bad_apple_' + str(a) + '.png'
	elif a > 9:
		img = 'bad_apple_0' + str(a) + '.png'
	else:
		img = 'bad_apple_00' + str(a) + '.png'
    
	image = cv2.imread('../image_sequence/' + img, 2)
	resized = cv2.resize(image, (80, 24))

	# frame = cv2.imread('../resized/'+ img, 2)
	ret, bw_frame = cv2.threshold(resized, 130, 255, cv2.THRESH_BINARY)
	bw = cv2.threshold(resized, 130, 255, cv2.THRESH_BINARY)
	binarize_image(bw_frame, '../data/' + img.removesuffix('.png') + '.data', a)

	print('\rformatted frame: ' + str(a) + ' / ' + str(count), end='')

	a += 1

src_dir = '../src/'
generate_asm_include(src_dir + 'frames.asm')

main_end = time.time()
print('\nTotal Time: ' + main_end-main_start)