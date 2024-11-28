from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg, length):
    return msg + urandom(length - len(msg))

n = 10
p = getPrime(256)
A = Matrix(Zmod(p), n, n, pad(flag,n^2))
PR.<x> = PolynomialRing(Zmod(p))
B = PR.random_element(degree=n)(A)

print("p =", p)
print("B =", B.list())