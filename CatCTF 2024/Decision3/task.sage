from Crypto.Util.number import *
from random import *
from secret import flag

flag_bin = bin(bytes_to_long(flag))[2:].zfill(len(flag)*8)

p = 26734989077687468135677691953151
F.<i> = GF(p^2, modulus = x^2 + 1)
E = EllipticCurve(j=F(1728))

def iter():
    global E
    for i in range(10):
        P = E(0).division_points(randint(2,3))[1:]
        shuffle(P)
        phi = E.isogeny(P[0])
        E = phi.codomain()

def F0():
    iter()
    phi = E.isogeny(E(0).division_points(2)[1])
    E1 = phi.codomain()
    return (E.montgomery_model().a2() + getrandbits(13), E1.montgomery_model().a2() + randint(0,p))

def F1():
    iter()
    phi = E.isogeny(E(0).division_points(3)[1])
    E1 = phi.codomain()
    return (E.montgomery_model().a2() + getrandbits(13), E1.montgomery_model().a2() + randint(0,p))

print("output =", [F0() if i == "0" else F1() for i in flag_bin])