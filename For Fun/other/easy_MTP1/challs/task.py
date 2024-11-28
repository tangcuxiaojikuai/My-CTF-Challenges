from Crypto.Util.number import *
from random import *
from secret import flag
from os import urandom
from pwn import xor

def pad(msg,length):
    return msg + urandom(length-len(msg))

def random_shift(msg):
    bit = randint(1,8*len(msg))
    temp = bytes_to_long(msg)
    left = (temp << bit) & ((1 << (8*len(msg))) - 1)
    right = temp >> (8*len(msg) - bit)
    return long_to_bytes(left | right)

def gen_mask(length):
    table = [long_to_bytes(i) for i in range(128,256)] #use non-printable character
    mask = [choice(table) for i in range(length)]
    return b"".join(mask)

length = 2024
flag = flag.strip(b"NSSCTF{").strip(b"}")
flag = pad(flag,length)
mask = gen_mask(length)

out = []
rounds = 2024
for i in range(rounds):
    out.append(xor(flag,random_shift(mask)))

with open("output.txt","w") as f:
    f.write(str(out))