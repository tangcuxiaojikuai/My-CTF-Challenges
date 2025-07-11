from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5
from secret import flag
import string

p, q, r, x, y = [getPrime(256) for _ in range(3)] + [getPrime(256) << 128 for _ in range(2)]
secret = "".join([choice(string.ascii_letters) for _ in range(77)])
PR.<i, j, k> = QuaternionAlgebra(Zmod(p*q), -x, -y)
print("🎁 :", [p*q] + list(PR([x+y, p+x, q+y, r])^bytes_to_long(777*secret.encode())) + [AES.new(key=md5(secret.encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag).hex()])