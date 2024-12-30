from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5
from random import choice, randint
from secret import flag

p = getPrime(64)
e = [randint(0, p), randint(0, p)]

m, n = 220, 137
s = random_vector(Zmod(p), n)
A = random_matrix(Zmod(p), m, n)
e = vector(Zmod(p), [choice(e) for i in range(m)])
b = A*s + e

print("A =", A.list())
print("b =", b.list())
print("c =", AES.new(key=md5(str(s).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag).hex())
print("p =", p)