from Crypto.Util.number import *
from random import *
from secret import flag

flag_bin = bin(bytes_to_long(flag))[2:].zfill(len(flag)*8)

def F0():
    while(1):
        E = random_matrix(Zmod(n), 4, 4)
        if(E.rank() == 4):
            break
    return (E * Matrix(Zmod(n), 4, 4, [randint(0,3) for i in range(16)]) * E^(-1)).list()

def F1():
    while(1):
        T = random_matrix(Zmod(n), 4, 4)
        if(T.rank() == 4):
            return T.list()

n = 65537
print("output =", [F0() if i == "0" else F1() for i in flag_bin])