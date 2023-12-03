# https://pages.mtu.edu/~suits/NoteFreqCalcs.html

n = -23 # where n is the no. of semitones 
# away from A4 (-ve for below, +ve for above)
a = 2 ** (1/12)
print(a)
desired_value = 440 * (a**n)
print(desired_value)



# LOWER_(letter, A-G), MIDDLE, UPPER
n = -23 # from A4 to Bb3 (lower_Bb)

while n <= 23:
    desired_value = 440 * (a**n)
    
    BF = 14318180  # base frequency
    IF = 12 * desired_value # input frequency
    print(IF)
    OUT = BF / IF # value sent to PIT
    print(OUT)
    
    n += 1

l = "LOW_"
m = "MID_"
u = "UPP_"
counter = 0
def test():
    if counter < 7:
        print(l)



# round value to nearest even integer
# next_even = desired_value % 2 
# if next_even < 1:
#     #round down desired value
# else:
#     #round up desired value
#     return


