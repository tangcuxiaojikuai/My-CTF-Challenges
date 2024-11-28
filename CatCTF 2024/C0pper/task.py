from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg, length):
    return msg + urandom(length - len(msg))

m1 = bytes_to_long(pad(flag[:len(flag)//2],128))
m2 = bytes_to_long(pad(flag[len(flag)//2:],128))
p,q = getPrime(512),getPrime(512)
n = p*q

print("n =",n)
print("c1 =",pow(m1,3,n))
print("c2 =",(pow(m1,7,n) + getPrime(128)))
print("c3 =", pow(m2,333,n))
print("c4 =", pow(m2,667,n) + getPrime(128))
print("c5 =", pow(m2,997,n) + getPrime(128))