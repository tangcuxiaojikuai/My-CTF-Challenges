from Crypto.Util.number import *
from random import randint
from secret import flag

p = getPrime(256)

print("p =", p)
print("c =", randint(1,p)*vector(Zmod(p), [i*getPrime(128) for i in flag]))