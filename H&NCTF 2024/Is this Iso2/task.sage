from Crypto.Util.number import *
from random import *
from secret import flag

def nextPrime(p):
    while(not isPrime(p)):
        p += 1
    return p


#part1 gen Fp and init supersingular curve
while(1):
    p = 2^randint(250,300)*3^randint(200,250)*5^randint(150,200)-1
    if(isPrime(p)):
        break

F.<i> = GF(p^2, modulus = x^2 + 1)
E = EllipticCurve(j=F(1728))
assert E.is_supersingular()


#part2 find a random supersingular E
ways = [2,3,5]
for i in range(20):
    P = E(0).division_points(choice(ways))[1:]
    shuffle(P)
    phi = E.isogeny(P[0])
    E = phi.codomain()


#part3 gen E1 E2 E3
E1 = E

deg1 = 2
P = E1(0).division_points(deg1)[1:]
shuffle(P)
phi1 = E1.isogeny(P[0])
E2 = phi1.codomain()

deg2 = 5
P = E2(0).division_points(deg2)[1:]
shuffle(P)
phi2 = E2.isogeny(P[0])
E3 = phi2.codomain()


#part4 leak
unknown = 48
j1 = E1.j_invariant()
j2 = E2.j_invariant()
j3 = E3.j_invariant()

m = bytes_to_long(flag)
n = getPrime(int(j3[0]).bit_length())*nextPrime(int(j3[0]))

print("p =",p)
print("leak1 =",j1[0] >> unknown << unknown)
print("leak2 =",j1[1] >> unknown << unknown)
print("leak3 =",j2[0] >> unknown << unknown)
print("leak4 =",j2[1] >> unknown << unknown)
print("n =",n)
print("cipher =",pow(m,65537,n))