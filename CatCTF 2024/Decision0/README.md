## Decision0

+ Difficulty：Easy
+ Solved：11

<br/>

## Description

why I call this Decision0? Maybe you will know next week.

<br/>

## Hint

+ 本题需要sagemath环境

+ 在线sagemath环境已经足够解决本题：https://sagecell.sagemath.org/ 但是下一周的所有题目都涉及sagemath的使用，所以还是建议配好环境

+ determinant or trace

<br/>

## Solution

题目是一个按flag比特的decision：

+ 若当前bit为0，则输出：
  $$
  C_0 = EAE^{-1} \quad(mod\;65537)
  $$
  其中E为模65537下的随机满秩矩阵，A为由0-3的小值组成的矩阵。

+ 若当前bit为1，则输出：
  $$
  C_1 = T \quad(mod\;65537)
  $$
  T为模65537下的随机满秩矩阵。

#### det

解题思路也很简单，若当前bit为1，那么C1的行列式也可以看作是模65537下的随机值。而如果当前bit为0，则有：
$$
|C_0| = |EAE^{-1}| = |A| \quad(mod\;65537)
$$
由于A由一些小值组成，所以其行列式在整数意义下较小，因此应该与65537的差值很小。通过此依据就可以对flag的每一bit做出decision。

#### trace

实际上，更进一步可以看出第一步的C和A是相似矩阵，所以其迹应该相等，因此计算C的迹，应该落在0-12以内，就可以做出decision。

#### 优化

对于Decision类题目，有两个统一的优化在于：

+ 不用计算flag前后缀"catctf{}"对应的所有bit
+ 不用计算每个字节的MSB，因为可见字符MSB一定是0

这类优化对本题目效果不明显，但在单次bit判断耗时相对长时（如Decision3），能有效节省时间。

#### 完整exp

```python
from Crypto.Util.number import *
from tqdm import *

output = 
output = output[7*8:-8]
n = 65537


#################################################### det
flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    M = Matrix(Zmod(n), 4, 4, output[bit])
    if(min(n-M.det(), M.det()) < 200):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#################################################### trace
flag = ""
for bit in trange(len(output)):
    if(bit % 8 == 0):
        flag += "0"
        continue

    M = Matrix(Zmod(n), 4, 4, output[bit])
    if(int(M.trace()) <= 12):
        flag += "0"
    else:
        flag += "1"
    
    if(bit % 8 == 7):
        print(long_to_bytes(int(flag,2)))


#catctf{P@y_4tt3nT1on_70_Det}
```
