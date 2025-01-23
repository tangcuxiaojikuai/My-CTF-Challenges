from random import *
from hashlib import *
from secret import flag

def SHUFFLE(t):
    temp = list(t)
    shuffle(temp)
    return "".join(temp)

print("c =", [SHUFFLE(choice([md5, sha1, sha384, sha256, sha512])(flag[:i]).hexdigest() + "".join([choice("0123456789abcdef") for _ in range(36)])) for i in range(1,len(flag)+1)])