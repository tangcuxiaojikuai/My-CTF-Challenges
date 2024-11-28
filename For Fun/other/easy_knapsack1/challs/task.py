from Crypto.Util.number import *
from random import *
from secret import flag

flag = flag.strip(b"NSSCTF{").strip(b"}")
flag_bin = bin(bytes_to_long(flag))[2:]

g = 2
length = len(flag_bin)
p = getPrime(700)
q = getPrime(700)
n = p*q
bag = list(map(int,flag_bin))
A = [randint(1,n-1) for i in range(length)]


s = 1
for i in range(length):
    s *= pow(g,(bag[i]*A[i]),n**2)
    s %= n**2

with open("output.txt","w") as f:
    f.write("p = " + str(p) + "\n")
    f.write("q = " + str(q) + "\n")
    f.write("gA = " + str([pow(g,A[i],n**2) for i in range(length)]) + "\n")
    f.write("s = " + str(s) + "\n")