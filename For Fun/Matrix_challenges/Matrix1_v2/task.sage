from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg, length):
    return msg + urandom(length - len(msg))

n = 5
p = getPrime(512)
M1 = Matrix(Zmod(p), n, n, pad(flag[:len(flag)//2],n^2))
M2 = Matrix(Zmod(p), n, n, pad(flag[len(flag)//2:],n^2))

A = random_matrix(Zmod(p), n, n)
B = M1*A*M2

print("p =", p)
print("A =", A.list())
print("B =", B.list())