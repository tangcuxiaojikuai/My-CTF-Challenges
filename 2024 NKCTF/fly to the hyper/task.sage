from Crypto.Util.number import *
from random import *
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
from hashlib import md5
from secret import flag


extend = 180
F = GF(2^extend, 'z', modulus = x^180+x^3+1)
z = F.gens()[0]
PRx = PolynomialRing(F,"x")
x = PRx.gens()[0]
h = x^2 + 1
f = x^5 + x^2 + 1
H = HyperellipticCurve(f, h)
J = H.jacobian()

def gen_point():
    while(1):
        try:
            a = F.from_integer(randint(1,2^extend-1))
            PRy.<y> = PolynomialRing(F,"y")
            y = PRy.gens()[0]
            curve = y^2 + h(a)*y - f(a)
            y , k = curve.roots()[0]
            if(k == 1):
                return J(H(a , y))
        except:
            pass


length = 80
table = [long_to_bytes(i) for i in range(128,256)]
password = b"".join([choice(table) for i in range(length//8)])
temp = bin(bytes_to_long(password))[2:].zfill(length)

bag = [int(i) for i in temp]
points = [5*gen_point() for i in range(length)]


s = J(0)
for i in range(length):
    if(bag[i]):
        s += points[i]
points = [(i[0],i[1]) for i in points]


#encrypt
key = md5(password).digest()
enc = AES.new(key,mode = AES.MODE_ECB)
c = enc.encrypt(pad(flag,16))


print("s =",(s[0],s[1]))
print("points =",points)
print("c =",c)