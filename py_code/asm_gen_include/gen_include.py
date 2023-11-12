import time

a = 1
b = 3
count = 6562
dest = 'asm_include.txt'
outfile = open(dest, 'w')

start = time.time()
while (a <= count):
    if a > 99:
        include = '\n%include "data/bad_apple_' + str(a) + '.data"\n'
        buffer = 'times ' +str(b) + ' * 256 - ($-$$) db 0'
        addition = include + buffer
        outfile.write(str(addition))
        #print(addition)
        a += 1
        b += 1
    else:
        include = '\n%include "data/bad_apple_0' + str(a) + '.data"\n'
        buffer = 'times ' +str(b) + ' * 256 - ($-$$) db 0'
        addition = include + buffer
        
        outfile.write(str(addition))
        #print(addition)
        a += 1
        b += 1

#dest = 'asm_include.txt'
# with open(dest, 'w') as dest:
#     dest.write(str(file))
    
end = time.time()
print('total time ' + str(end-start))