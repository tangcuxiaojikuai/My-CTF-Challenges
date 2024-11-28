from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg, length):
    return msg + urandom(length - len(msg))

def F(A):
    res = Matrix(Zmod(p), n, n)
    for i in range(len(f)):
        res += A^(i+1)*f[i]
    return res

n = 7
p = getPrime(256)
f = [Matrix(Zmod(p), n, n, pad(flag,n^2)) for i in range(n)]

C = []
for i in range(1):
    A = random_matrix(Zmod(p), n, n)
    C.append([A.list(),F(A).list()])

print("p =", p)
print("C =", C)