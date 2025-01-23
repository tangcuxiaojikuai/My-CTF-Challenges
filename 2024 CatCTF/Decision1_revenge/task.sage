from Crypto.Util.number import *
from random import *
from secret import flag

flag_bin = bin(bytes_to_long(flag))[2:].zfill(len(flag)*8)

def F0():
    f = lambda x: sum((poly[i])*pow(x,i,n) for i in range(len(poly))) % n
    poly = [randint(0,n) for _ in range(40)]
    return [f(j) + getrandbits(1) for j in range(80)]

def F1():
    return [randint(1,n) for j in range(80)]

n = getPrime(128)
print("n =", n)
print("output =", [F0() if i == "0" else F1() for i in flag_bin])