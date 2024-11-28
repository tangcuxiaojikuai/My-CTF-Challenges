from Crypto.Util.number import *
from os import urandom
from secret import flag

def pad(msg,length):
    return msg + urandom(length - len(msg))

p = getPrime(30)
dim = 60
m = pad(flag,dim^2)
A = random_matrix(Zmod(p),dim,dim)
B = random_matrix(Zmod(p),dim,dim)
X = Matrix(Zmod(p),dim,dim,m)

for i in range(1,4):
    X = A*X + B
    print(f"X{i} = {list(X)}")