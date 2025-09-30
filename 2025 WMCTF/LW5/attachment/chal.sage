from Crypto.Cipher import AES
from ast import literal_eval
from random import choice
from hashlib import md5
from secret import flag

def check(E):
    assert len(set([_ % p for _ in E])) == 5
    L = block_matrix(ZZ, [
        [Matrix(ZZ, E)],
        [Matrix(ZZ, [1]*5)],
        [p]
    ])
    E_ = L.LLL()[3]
    return max([abs(_) for _ in E_]) > 1337 and min([abs(_) for _ in E_]) > 337
    
p = 1048583
E = literal_eval(input("your error plz :)"))
assert check(E)

m, n = 90, 56
s = random_vector(Zmod(p), n)
A = random_matrix(Zmod(p), m, n)
e = vector(Zmod(p), [choice(E) for i in range(m)])
b = A*s + e

print("🎁 :", A.list() + b.list())
print("🚩 :", AES.new(key=md5((str(s)).encode()).digest(), nonce=b"Tiffany", mode=AES.MODE_CTR).encrypt(flag))