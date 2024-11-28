from Crypto.Util.number import *
from random import randint
from secret import flag

n = len(flag)
p = getPrime(256)

def encrypt(n,p,msg):
    while(1):
        L = [msg]
        R = [randint(1,p)*msg]
        for i in range(n-1):
            temp = random_vector(Zmod(p), n)
            L.append(temp)
            R.append(randint(1,p)*temp)
        L = Matrix(Zmod(p),L).T
        R = Matrix(Zmod(p),R).T
        if(L.rank() == n and R.rank() == n):
            return (R*L^(-1))^(bytes_to_long(b"Tequila"))

print("p =", p)
print("C =", encrypt(n,p,vector(Zmod(p),flag)).list())