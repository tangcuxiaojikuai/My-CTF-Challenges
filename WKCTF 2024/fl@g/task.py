from Crypto.Util.number import *
from sympy import *
from tqdm import *
from secret import flag
from itertools import *
from math import factorial
import string

table = string.ascii_letters + string.digits + "@?!*"

def myprime():
    num = 0
    for i in tqdm(permutations(table) , total=factorial(len(table))):
        temp = "".join(list(i))
        if("flag" in temp or "FLAG" in temp or "f14G" in temp or "7!@9" in temp or "🚩" in temp):
            num += 1
    return nextprime(num)

m = bytes_to_long(flag)
n = myprime()*getPrime(300)
c = pow(m,65537,n)

print("n =",n)
print("c =",c)


'''
n = 10179374723747373757354331803486491859701644330006662145185130847839571647703918266478112837755004588085165750997749893646933873398734236153637724985137304539453062753420396973717
c = 1388132475577742501308652898326761622837921103707698682051295277382930035244575886211234081534946870195081797116999020335515058810721612290772127889245497723680133813796299680596
'''