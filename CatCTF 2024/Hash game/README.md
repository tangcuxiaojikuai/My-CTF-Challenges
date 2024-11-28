## Hash game

+ Difficulty：Easy
+ Solved：16

<br/>

## Description

Play a hash game with bear!

<br/>

## Hint

+ 根据密文长度，判断当前密文究竟调用的是哪种哈希算法

+ shuffle只改变顺序，不改变各个十六进制字符数量

<br/>

## Solution

题目基于哈希，总共给出flag长度那么多次密文，第i次的加密步骤为：

+ 从md5, sha1, sha384, sha256, sha512中随机选择一个当作本次的哈希函数，记为hashi

+ 将flag的前i个字符组成的串作为本次哈希对象，记为mi

+ 随机选择36个十六进制字符当作扰动，记为ei

+ 给出本次密文ci：
  $$
  c_i = shuffle(hash_i(m_i) + e_i)
  $$
  其中加号为字符串连接，shuffle的作用是随机打乱字符串顺序

首先，对于每一个密文，我们要先判断出究竟其用的是哪一种哈希算法，而判断依据在于哈希值长度的不同。对于题目的五种算法来说，他们的哈希值长度分别为：

+ md5：128bit
+ sha1：160bit
+ sha256：256bit
+ sha384：384bit
+ sha512：512bit

而每个密文都会多出36个随机十六进制字符，因此十六进制长度减去36之后，就可以通过比特长度判断究竟是哪一种哈希算法了。

之后就是想办法还原flag，由于每一次哈希的对象是flag的前i个字符，因此第一次哈希对象就是flag的第一个字符，此时爆破空间很小，就是可见字符对应的ASCII码，也就是32-128内。

> 不过既然知道flag头"catctf{"，可以从第八个字符开始上述过程

此时我们可以用本次密文对应的哈希算法对这个小范围内所有字符逐个求哈希，但是由于每次密文做了如下处理：

+ 有36个随机十六进制字符扰动
+ 打乱了顺序

所以我们没办法直接通过对比哈希值是否相等，来判断当前究竟是哪个字符正确。然而，由于shuffle只会打乱顺序，不会改变哈希值每种十六进制字符的个数，因此对于正确的被哈希串来说，其一定会满足：

+ 哈希值的所有十六进制字符数量均小于等于对应密文十六进制字符数量

由此我们就可以找到一些符合条件的字符串，在这些字符串的基础上，我们继续向后搜索，用DFS的思路逐步减小范围，最后就可以得到正确的flag串了。

exp：

```python
from hashlib import *

c = 

def check_chr(a, t1, t2):
    return t1.count(a) <= t2.count(a)   

noise_num = 36
def check_str(msg, t):
    if(len(t) == 32 + noise_num):
        return all(check_chr(a, md5(msg.encode()).hexdigest(), t) for a in "0123456789abcdef")
    elif(len(t) == 40 + noise_num):
        return all(check_chr(a, sha1(msg.encode()).hexdigest(), t) for a in "0123456789abcdef")
    elif(len(t) == 64 + noise_num):
        return all(check_chr(a, sha256(msg.encode()).hexdigest(), t) for a in "0123456789abcdef")
    elif(len(t) == 96 + noise_num):
        return all(check_chr(a, sha384(msg.encode()).hexdigest(), t) for a in "0123456789abcdef")
    elif(len(t) == 128 + noise_num):
        return all(check_chr(a, sha512(msg.encode()).hexdigest(), t) for a in "0123456789abcdef")

def find(flag):
    if(not check_str(flag, c[len(flag)-1])):
        return
    
    if(len(flag) == len(c)):
        print(flag)
        return
    
    for i in range(32,127):
        find(flag + chr(i))


find("c")


#catctf{Just_p1@Y_A_S1mP1E_H@SH_g4Me_W17H_DFS_I_gu3ss!}
```
