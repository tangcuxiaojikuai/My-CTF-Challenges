from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg, length):
    return msg + urandom(length - len(msg))

n = 10
p = getPrime(256)
M = Matrix(Zmod(p), n, n, pad(flag,n^2))
e = Matrix(Zmod(p), n, n, pad(b"",n^2))
W = random_matrix(Zmod(p), n, n)
X = random_matrix(Zmod(p), n, n)
Y = random_matrix(Zmod(p), n, n)
Z = random_matrix(Zmod(p), n, n)

C = W*X*M*Y*Z+e

print("p =", p)
print("W =", W.list())
print("X =", X.list())
print("Y =", Y.list())
print("Z =", Z.list())
print("C =", C.list())