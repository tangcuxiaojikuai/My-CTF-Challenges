## MT-SS

+ Difficulty：Hard
+ Solved：2

<br/>

## Description

Another brand-new MT challenge

<br/>

## Hint

+ 三rd十一个新的开始！


<br/>

## Solution

题目的SS函数其实完全就是上一题的N函数，只是为了起题目标题所以用了另一个名字XD，这一题的区别在于是给了50000次的如下结果：
$$
SS(SS(5))
$$
但其实上一题明白道理的话，这个题目完全就是一样的，挑选gift中满31bit的数字，就说明内层的SS(5)结果是31，外层的SS(31)结果是gift中的值，这就获得了36bit的结果，凑够19968bit就行了。

exp：

```python
from Crypto.Util.number import *
from output import gift,c
from random import *
from tqdm import *

if(0): #test
    RNG1 = Random()
    print(RNG1.getstate())
    def SS(k):
        return RNG1.getrandbits(1) & 0 if k == 0 else RNG1.getrandbits(k)
    gift = []
    for i in range(50000):
        gift.append(SS(SS(5)))


############################################################ part1 get state
RNG = Random()
length = 19968

def construct_a_row(RNG):
    ind = 0
    row = []
    while(1):
        if(len(bin(gift[ind])[2:]) == 31):
            t1 = bin(RNG.getrandbits(5))[2:].zfill(5)
            for tt in t1:
                row.append(int(tt))
            t2 = bin(RNG.getrandbits(31))[2:].zfill(31)
            for tt in t2:
                row.append(int(tt))
        else:
            RNG.getrandbits(32)
            RNG.getrandbits(32)
        if(len(row) >= length):
            return row
        ind += 1


L = []
for i in trange(length):
    state = [0]*624
    temp = "0"*i + "1"*1 + "0"*(length-1-i)
    for j in range(624):
        state[j] = int(temp[32*j:32*j+32],2)
    RNG.setstate((3,tuple(state+[624]),None))
    L.append(construct_a_row(RNG))

L = Matrix(GF(2),L)

known = []
for i in gift:
    if(len(bin(i)[2:]) == 31):
        known += [1,1,1,1,1]
        known += list(map(int,bin(i)[2:]))
        if(len(known) >= length):
            break
s = L.solve_left(vector(GF(2),known))
init = "".join(list(map(str,s)))
for i in range(624):
    state.append(int(init[32*i:32*i+32],2))


############################################################ part2 get flag
RNG2 = Random()
RNG2.setstate((3,tuple(state+[624]),None))
def SS(k):
    return RNG2.getrandbits(1) & 0 if k == 0 else RNG2.getrandbits(k)
for i in range(50000):
    SS(SS(5))

print(long_to_bytes(RNG2.getrandbits(500)^^bytes_to_long(c)))


#NSSCTF{Bec4us3_0f_LinearXD!!}
```

