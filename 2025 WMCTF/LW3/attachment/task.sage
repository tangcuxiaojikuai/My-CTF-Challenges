from random import choice, sample
from Crypto.Cipher import AES
from hashlib import md5
from secret import flag

m, n = 90, 64
p = 1048583

E = sample(range(1, p), 3)
s = random_vector(Zmod(p), n)
A = random_matrix(Zmod(p), m, n)
e = vector(Zmod(p), [choice(E) for i in range(m)])
b = A*s + e

print("🎁 :", E + A.list() + b.list())
print("🚩 :", AES.new(key=md5((str(s)).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag))