from Crypto.Util.number import *
from Crypto.Cipher import AES
from random import randint
from hashlib import md5
from secret import flag

n = len(flag)
p = getPrime(256)
secret = [randint(1,p) for i in range(n)]

def encrypt(n,p,msg):
    while(1):
        L = []
        R = []
        for i in range(n):
            temp = random_vector(Zmod(p), n)
            L.append(temp)
            R.append(msg[i]*temp)
        L = Matrix(Zmod(p),L).T
        R = Matrix(Zmod(p),R).T
        if(L.rank() == n and R.rank() == n):
            return (R*L^(-1))^(bytes_to_long(b"Tequila"))

print("p =", p)
print("C =", encrypt(n,p,vector(Zmod(p),secret)).list())
print("enc =", AES.new(key=md5(str(sum(secret)).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag))