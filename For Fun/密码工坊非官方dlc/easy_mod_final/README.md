## easy_mod_final

+ Difficulty：Hard

## Solution

题目的核心trick和mod3其实一致，回看mod3，我们是找到了一种方法，将N,s的ASCII码值，也就是78、115，分别对应到了0、1，从而减小了目标向量的数量级。而现在值变成了G、A、M、E四个，似乎好像不那么好处理了。

此时就要提取一下把78、115变到0、1的本质，这其实是一个线性变换，也就是：
$$
y = ax + b \quad(mod\;p)
$$
而(78,0)、(115,1)是这个直线上的两个点，因此可以唯一确定a、b，确定了a、b后就可以对格的各个数值也进行相应的线性变换处理(详见mod3)，从而使目标向量规约出0、1来。

那么对于final这个题目，我们的根本目的也就可以抽象成：**找到一个线性变换，使得GAME四个字母均在这条直线上，并且纵坐标均很小，从而可以规约**。

但是由于两点就确定了一条直线，所以随意取纵坐标的话似乎很难恰好满足四点共线(不过就单对于这题来说不存在，因为你知道要变到比较小的值，所以可以在0附近的小数字爆破纵坐标来检查共线)。因此，一个合理的办法是检查这四个点横坐标之间的关系来确定线性变换的差值。

听上去可能有点抽象，不妨就以GAME这四个字母展开，我们把他们按顺序排列为A、E、G、M，其ASCII码差值分别为4、2、6，因此一定可以找到一个变换，使得依次排列的四个点，纵坐标差值的比例为2：1：3。

这是为什么呢？可以把四个点在直线上的方程先写出来：
$$
y_1 = ax_1 + b \quad(mod\;p)
$$

$$
y_2 = ax_2 + b \quad(mod\;p)
$$

$$
y_3 = ax_3 + b \quad(mod\;p)
$$

$$
y_4 = ax_4 + b \quad(mod\;p)
$$

两两作差就有：
$$
y_1 - y_2 = a(x_1 - x_2) \quad(mod\;p)
$$

$$
y_2 - y_3 = a(x_2 - x_3) \quad(mod\;p)
$$

$$
y_3 - y_4 = a(x_3 - x_4) \quad(mod\;p)
$$

纵坐标差值的比例等于横坐标差值的比例，也就是2：1：3。而在此基础上我们可以任意选择最满足规约要求的两个基准点来确定直线，与此同时就能确定另外两点的纵坐标。

比如这题，我们就可以选择(G,0)、(E,1)为两个基准点来确定线性变换，然后就得到另外两个点(A,3)、(M,-3)，此时对格做mod3类似的处理，预期就可以规约出全部由3、1、0、-3组成的短向量了。

exp：

```python
from Crypto.Util.number import *
from random import *


p = 2271129678202363707972156644097566224560370806295266873816026779022614695317611229903770390498322537051358521932851893609555063610221
c = 244176818026839545554951436126300508547217557099550914232243928051857553603712968234687200629719468115535825237511413058786560692170
table = [ord(i) for i in "AEGM"]

#part1 linear transformation and remove prefix and suffix
a = 1 * inverse(table[1]-table[2],p)
b = (1 - a*table[1]) % p
prefix = b"NSSCTF{"
suffix = b"}"
length = 108 - len(prefix) - len(suffix)
c -= 256^(len(suffix) + length) * bytes_to_long(prefix)
c -= bytes_to_long(suffix)
c = c * inverse(256,p) % p
c = a*c % p

#part2 BKZ

L = Matrix(ZZ,length+2,length+2)
for i in range(length):
    L[i,i] = 1
    L[i,-1] = 256^i
    c += 256^i*b
    c %= p

L[-2,-2] = 1
L[-2,-1] = -c
L[-1,-1] = p
L[:,-1:] *= p
res = L.BKZ()

flag = ""
for i in res[:-1]:
    if(all(abs(j) <= 3 for j in i[:-2])):
        if(1 in i):
            for j in i[:-2][::-1]:
                if(j == 1):
                    flag += "E"
                elif(j == 3):
                    flag += "A"
                elif(j == 0):
                    flag += "G"
                else:
                    flag += "M"
        else:
            for j in i[:-2][::-1]:
                if(j == -1):
                    flag += "E"
                elif(j == -3):
                    flag += "A"
                elif(j == 0):
                    flag += "G"
                else:
                    flag += "M"
print(flag)


#NSSCTF{GEEGEEEMEEMMAAMGGGGEEGMMAMEGGEEEGAGGMEMEMMAMGGGEAAGMGEAAGEMMEEEMGMAAMMGEAAEEEEEGGEMMMMAEGAAAMEMEAEGE}
```

