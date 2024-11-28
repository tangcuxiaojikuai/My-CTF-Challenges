from Crypto.Util.number import *
from secret import flag
from random import *

def N(k):
    return getrandbits(1) & 0 if k == 0 else getrandbits(k)

gift = []
for i in range(100000):
    gift.append(N(N(N(1))))

key = getrandbits(500)
c = bytes_to_long(flag)^key

with open("output.txt", "w") as f:
    f.write(f"gift = {gift}\n")
    f.write(f"c = {long_to_bytes(c)}")