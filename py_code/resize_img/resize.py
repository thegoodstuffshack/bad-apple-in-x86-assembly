from PIL import Image
import time

count = 6562
a = 1
start = time.time()

while(a <= count):
    if a > 99:
        img = 'bad_apple_' + str(a) + '.png'
        
        image = Image.open('og-frames/' + img)
        variable = image.resize((80, 24))
        variable.save('resized-frames/' + img)
        
        a += 1
    else:
        img = 'bad_apple_0' + str(a) + '.png'
        
        image = Image.open('og-frames/'+ img)
        variable = image.resize((80, 24))
        variable.save('resized-frames/' + img)
    
        a += 1

end = time.time()
print(end-start)
