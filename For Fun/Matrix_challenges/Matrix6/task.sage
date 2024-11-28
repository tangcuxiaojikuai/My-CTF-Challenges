from Crypto.Util.number import *
from random import randint
from secret import flag

polyeval = lambda poly, x: sum(a*pow(x,i,n) for a,i in poly) % n

p = getPrime(256)
q = getPrime(256)
n = p*q
e = 1337
m = bytes_to_long(flag)

nums = 10
g = [(randint(1,n), i) for i in range(nums)]
F = []
C = []
for i in range(nums+1):
    f = [(randint(1,n), (randint(1,n))) for i in range(nums)]
    F.append(f)
    C.append(polyeval(g,polyeval(f,m)))

print("n =", n)
print("c =", pow(m,e,n))
print("F =", F)
print("C =", C)