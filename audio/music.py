from math import floor
from math import ceil


# https://pages.mtu.edu/~suits/NoteFreqCalcs.html
n = -21
BF = 14318180

notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
octaves = ['lorem_ipsum', 'LOW', 'MID', 'UPP', 'HIGH']
count = m = 0
o = 1

dict = dict([])

# Generate the pre
while count < 48:
    note = octaves[o] + '_' + notes[m] + '\tdw '
    #print(note)
    
    if count == 11:
        o = 2
    elif count == 23:
        o = 3
    elif count == 35:
        o = 4
    
    m += 1
    if m >= 12:
        m = 0

    freq = 440 * (2**(1/12))**n
    print(freq)

    input_Hz = BF / freq

    even_num = input_Hz % 2
    if even_num == 1:
        input_Hz += 1
    if even_num < 1:
        input_Hz = floor(input_Hz)
    else:
        input_Hz = ceil(input_Hz)

    print(input_Hz)


    final = note + hex(input_Hz)
    print(final)
    dict[count] = final

    n += 1
    count += 1
    
# for d in dict:
#     print(dict[d])
dest = "note_defs.data"

with open(dest, 'w') as dest:
    for d in dict:
        dest.write(dict[d] + '\n')