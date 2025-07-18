import random

for i in range(16):
    k = random.randrange(0,2**16)
    k_shift = k << 1
    print(i, k, bin(k)[2:].zfill(16))
    print(i, k_shift, bin(k_shift)[2:].zfill(16), end="\n"*2)

