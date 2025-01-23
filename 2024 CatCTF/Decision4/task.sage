from Crypto.Util.number import *
from random import *
from secret import flag

flag_bin = bin(bytes_to_long(flag))[2:].zfill(len(flag)*8)
        
p = 65537
F = GF(p)
n, k = 40, 12
C = codes.GeneralizedReedSolomonCode(F.list()[:n], k)
Co = C.encoder()

def gen():
    temp = randint(0,n)
    return matrix(Permutation([i for i in range(1,n+1)][temp:] + [i for i in range(1,n+1)][:temp]))

def F0():
    err = [randint(1,p-1) for i in range(k)] + [0]*(n-k)
    shuffle(err)
    return (gen() * Co.encode(vector(F,[randint(0,p) for i in range(k)])) + gen() * vector(F,err)).list()
    
def F1():
    err = [randint(1,p-1) for i in range(k-1)] + [0]*(n-k+1)
    shuffle(err)
    return (gen() * Co.encode(vector(F,[randint(0,p) for i in range(k)])) + gen() * vector(F,err)).list()

print("output =", [F0() if i == "0" else F1() for i in flag_bin])