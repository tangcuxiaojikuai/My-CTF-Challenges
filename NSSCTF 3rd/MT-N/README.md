## MT-N

+ Difficulty：Middle
+ Solved：2

<br/>

## Description

A brand-new MT challenge

<br/>

## Solution

题目先定义了一个函数N，其基本上就是一个getrandbits函数，特殊性在于参数k=0时，依然会进行1bit的getrandbits。在此基础上，题目给出了100000次如下式子的结果：
$$
N(N(N(1)))
$$
并且以之后的500bit作为key与flag异或，也就是说要利用这给出的结果向后预测随机数，才能得到flag。

由以前MT的题型可以知道，如果我们知道了19968位getrandbits的结果以及这些比特位的位置，那么就可以构造矩阵来解线性方程得到初始state，然后就可以向后预测随机数了。

而问题在于，题目的MT进行了三层嵌套，相当于每次实际上都是三个bit的结果复合而成的，没办法直接获得每个bit。但是可以发现，如果gift中结果为1，那么其对应的三层一定都是1，就相当于获得了3bit的已知结果，因此搜集到足够19968bit就可以建矩阵了。

exp：

```python
from Crypto.Util.number import *
from output import gift,c
from random import *
from tqdm import *

if(0): #test
    RNG1 = Random()
    print(RNG1.getstate())
    def N(k):
        return RNG1.getrandbits(1) & 0 if k == 0 else RNG1.getrandbits(k)
    gift = []
    for i in range(100000):
        gift.append(N(N(N(1))))


############################################################ part1 get state
RNG = Random()
length = 19968

def construct_a_row(RNG):
    ind = 0
    row = []
    while(1):
        if(gift[ind] == 0):
            RNG.getrandbits(1)
            RNG.getrandbits(1)
            RNG.getrandbits(1)
        elif(gift[ind] == 1):
            row.append(RNG.getrandbits(1))
            if(len(row) == length):
                return row
            row.append(RNG.getrandbits(1))
            if(len(row) == length):
                return row
            row.append(RNG.getrandbits(1))
            if(len(row) == length):
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
'''
#test (ttt is init state)
sss = ""
for i in ttt:
    sss += bin(i)[2:].zfill(32)
sss = list(map(int,sss))
sss = vector(GF(2),sss)
print(sss*L)
'''

s = L.solve_left(vector(GF(2),[1]*length))
init = "".join(list(map(str,s)))
state = []
for i in range(624):
    state.append(int(init[32*i:32*i+32],2))


############################################################ part2 get flag
RNG1 = Random()
RNG1.setstate((3,tuple(state+[624]),None))
def N(k):
    return RNG1.getrandbits(1) & 0 if k == 0 else RNG1.getrandbits(k)
for i in range(100000):
    N(N(N(1)))

print(long_to_bytes(RNG1.getrandbits(500)^^bytes_to_long(c)))


#NSSCTF{1st_year_2nd_year_And_now_is_3rd_not_4th_Do_U_know_why?}
```

