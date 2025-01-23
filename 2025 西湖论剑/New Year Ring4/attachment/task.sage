from random import randint, choice, shuffle
from Crypto.Util.number import *
from Crypto.Cipher import AES
from hashlib import md5
from secret import flag

p = getPrime(round(20.25))
a, b, d = randint(0, p), randint(0, p), 14
A, B, seed, secret = [], [], [randint(0, p) for _ in range(4)], [randint(0, p) for _ in range(d)]

PR.<x> = PolynomialRing(GF(p))
PRq = PR.quo(PR(list(b"DASCTF_XHLJ2025")))
for i in range(ord("🚩") % sum(list(map(ord, "flag")))):
    A += [PRq.random_element().list()]
    B += [(PRq(A[i]) * PRq(secret) + PRq([choice(seed) for _ in range(d)])).list()]
    seed = [(a * _ + b) % p for _ in seed]

print("A =", [a] + A)
print("B =", ["b"]+B)
print("C =", AES.new(key=md5(str([b]+seed+secret).encode()).digest(), nonce=b"Xenny.fans.club", mode=AES.MODE_CTR).encrypt(flag).hex())