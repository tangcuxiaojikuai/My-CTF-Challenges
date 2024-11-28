from Crypto.Util.number import *
from secret import flag
from random import *

gift = b"".join(long_to_bytes((pow(getrandbits(4), 2*i, 17) & 0xf) ^ getrandbits(8), 1) for i in range(4567))
m = list(flag)
for i in range(2024):
    shuffle(m)

print("gift =", bytes_to_long(gift))
print("c = '" +  "".join(list(map(chr,m))) + "'")