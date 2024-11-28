from Crypto.Util.number import *
from random import *
from secret import flag

flag_bin = bin(bytes_to_long(flag))[2:].zfill(len(flag)*8)

p = 0x3cb868653d300b3fe80015554dd25db0fc01dcde95d4000000631bbd421715013955555555529c005c75d6c2ab00000000000ac79600d2abaaaaaaaaaaaaaa93eaf3ff000aaaaaaaaaaaaaaabeab000b
E = EllipticCurve(GF(p), (0, 4))
n = E.order()
primes = [67, 5563, 2099837, 773517157085353949]

def F0():
    r1 = choice(primes)
    r2 = choice(primes)
    return ((n // r1^2)*E.random_element()).weil_pairing((n // r1^2)*E.random_element(),r1) * ((n // r2^2)*E.random_element()).weil_pairing((n // r2^2)*E.random_element(),r2) % p

def F1():
    return GF(p).random_element()^((p-1) // prod(primes))

print("output =", [F0() if i == "0" else F1() for i in flag_bin])