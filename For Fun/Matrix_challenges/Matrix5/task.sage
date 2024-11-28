from Crypto.Util.number import *
from random import randint
from secret import flag

n = len(flag)-4
p = getPrime(256)

def encrypt(n,p,msg):
    while(1):
        L = []
        R = []
        for i in range(n):
            temp = vector(Zmod(p), [randint(1,p) for _ in range(n-5)] + list(msg[i:i+5]))
            L.append(temp)
            R.append(randint(1,p)*temp)
        L = Matrix(Zmod(p),L).T
        R = Matrix(Zmod(p),R).T
        if(L.rank() == n and R.rank() == n):
            return (R*L^(-1))^(randint(1,p))

print("p =", p)
print("C =", encrypt(n,p,vector(Zmod(p),flag)).list())