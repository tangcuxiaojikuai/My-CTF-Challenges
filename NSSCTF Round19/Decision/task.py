from Crypto.Util.number import *
from random import *
from secret import flag
import string

class MRG:
    def __init__(self,para_len,p):
        self.init(para_len,p)

    def next(self):
        self.s = self.s[1: ] + [(sum([i * j for (i, j) in zip(self.a, self.s)]) + self.b) % self.p]
        return self.s[-1]

    def init(self,para_len,p):
        self.p = p
        self.b = randint(1, self.p)
        self.a = [randint(1, self.p) for i in range(para_len)]
        self.s = [ord(choice(string.printable)) for i in range(para_len)]
    
    def get_params(self):
        return [self.a,self.b,self.s[0]]


flag = bytes_to_long(flag)
flag_bin = bin(flag)[2:]

Round = 2024
A_len = 10
p = getPrime(256)

output = []
for i in flag_bin:
    if(i == "0"):
        temp = MRG(A_len,p)
        for j in range(Round):
            temp.next()
        output.append(temp.get_params())
    else:
        a = [randint(1,p) for i in range(A_len)]
        b = randint(1,p)
        s = randint(1,p)
        output.append([a,b,s])

with open("output.txt","w") as f:
    f.write(str(p))
    f.write(str(output))