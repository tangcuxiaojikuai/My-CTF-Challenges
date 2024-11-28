## easy_factor4

+ Difficulty：Middle

## Solution

题目给出一个hint：
$$
hint = ad^3 + t\phi(n)^2
$$
其中a、t分别是20bit、128bit的未知素数，要求利用此hint完成RSA的分解。

由于a仅有20bit，是一个可以爆破的范围，所以当前问题是用什么方式去爆破能够确定a的值。由于有d^3的存在，自然可以想到两边同乘e^3：
$$
e^3hint = a(ed)^3 + te^3\phi(n)^2
$$
又因为：
$$
ed = 1 + k\phi(n)
$$
所以：
$$
e^3hint = a(1 + k\phi(n))^3 + te^3\phi(n)^2
$$
也就是：
$$
e^3hint = a + K\phi(n)
$$
所以对于正确的a，有：
$$
2^{e^3hint-a} = 2^{K\phi(n)} = 1 \quad(mod\;n)
$$
因此就能确定a的值。

有了a之后，也就有了Kphi(n)的值：
$$
K\phi(n) = e^3hint - a
$$
所以就变成已知Kphi(n)和n求n的分解的问题了，无论是用factor1的方法去试除小因子，还是用网上的轮子都可以解决。

exp：

```python
from Crypto.Util.number import *
from Crypto.Util.Padding import *
from Crypto.Cipher import AES
from hashlib import sha256
from gmpy2 import *
from tqdm import *

n = 8218998145909849489767589224752145194323996231101223014114062788439896662892324765430227087699807011312680357974547103427747626031176593986204926098978521
c = b'\x9a \x8f\x96y-\xb4\tM\x1f\xe6\xcc\xef\xd5\x19\xf26`|B\x10N\xd7\xd0u\xafH\x8d&\xe3\xdbG\x13\x8e\xea\xc0N\n\r\x91\xdc\x95\x9b\xb1Ny\xc1\xc4'
hint = 1860336365742538749239400340012599905091601221664081527583387276567734082070898348249407548568429668674672914754714801138206452116493106389151588267356258514501364109988967005351164279942136862087633991319071449095868845225164481135177941404709110974226338184970874613912364483762845606151111467768789248446875083250614540611690257121725792701375153027230580334095192816413366949340923355547691884448377941160689781707403607778943438589193122334667641037672649189861

e = 65537

#part1 get a
if(0):
    for a in trange(2**20):
        if(not isPrime(a)):
            continue
        if(powmod(2,e**3*hint-a,n) == 1):
            print(a)
            break
a = 565237


#part2 factor n
kphi = e**3*hint - a
t = 3**3
p = GCD(pow(2,kphi//t,n)-1,n)
q = n // p


#part3 get flag
key = sha256(str(p+q).encode()).digest()
enc = AES.new(key, AES.MODE_ECB)
flag = enc.decrypt(c)
print(flag)


#NSSCTF{H0w_70_F4ct0R_N_7h1s_tim3?}
```

