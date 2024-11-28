from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5
from secret import flag

n = 10
A = random_matrix(GF(2), n, n)
PR.<x> = PolynomialRing(GF(2))
B = PR.random_element(degree=n)(A)

print("B =", B.list())
print("enc =", AES.new(key=md5(str(A).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag))