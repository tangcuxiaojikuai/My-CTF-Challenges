## Decision

+ Difficulty：Middle
+ Solved：1

<br/>

## Description

Make your decision

<br/>

## Hint

+ 初始状态好像并不是很随机
+ 初始状态在模p下显得很小
+ MRG的递推过程可以写成矩阵形式
+ 尝试利用该矩阵去LLL得到初始状态


<br/>

## Solution

题目基于一个系数共10项的MRG(Multiple Recursive Generator)，其递推公式为：
$$
s_{i+10} = \sum_{j=0}^{9}{a_{j}s_{i+j}} + b \quad(mod\;p)
$$
也就是说一个新状态由前十个状态共同决定。

题目的加密流程为：

+ 将flag转为二进制串
+ 依次遍历flag二进制串的每个bit，如果当前bit为0，则生成一个MRG，并且进行2024次迭代后，输出MRG的所有参数，包括系数a、b以及当前状态的第一个量；如果当前bit为1，则完全随机生成a、b、s

也就是说，我们需要判定每一组样本究竟是MRG样本还是随机样本，这有点像一个DLWE问题。但是判别的依据到底是什么？这里就需要注意到一个事实：每个新生成的MRG，其初始状态都是可见字符的ASCII码，这其实表明一个信息，那就是MRG的初始状态都是模p下的小量，所以就会联想到用格求解。

而MRG显然是一个线性的递推关系，因此每一次递推都可以用一个矩阵来表示(这个思路在之前0CTF也出现过)，比如说第一次递推就是：
$$
\left(
 \begin{matrix}
   s_1\\
   s_2\\
   s_3\\
   \vdots\\
   s_9\\
   s_{10}\\
   1\\
  \end{matrix}
  \right)
  =
\left(
 \begin{matrix}
   &1&&&&&\\
   &&1&&&&\\
   &&&1&&&\\
   &&&&\ddots&&\\
   &&&&&1&\\
   a_0&a_1&a_2&a_3&\cdots&a_9&b\\
   &&&&&&1\\
  \end{matrix}
  \right)
\left(
 \begin{matrix}
   s_0\\
   s_1\\
   s_2\\
   \vdots\\
   s_8\\
   s_9\\
   1\\
  \end{matrix}
  \right)
  \quad(mod\;p)
$$
那么2024次递推就有：
$$
\left(
 \begin{matrix}
   s_{0+2024}\\
   s_{1+2024}\\
   s_{2+2024}\\
   \vdots\\
   s_{8+2024}\\
   s_{9+2024}\\
   1\\
  \end{matrix}
  \right)
  =
\left(
 \begin{matrix}
   &1&&&&&\\
   &&1&&&&\\
   &&&1&&&\\
   &&&&\ddots&&\\
   &&&&&1&\\
   a_0&a_1&a_2&a_3&\cdots&a_9&b\\
   &&&&&&1\\
  \end{matrix}
  \right)
  ^{2024}
\left(
 \begin{matrix}
   s_0\\
   s_1\\
   s_2\\
   \vdots\\
   s_8\\
   s_9\\
   1\\
  \end{matrix}
  \right)
  \quad(mod\;p)
$$
而假设当前bit是0，也就是说我们拥有一个MRG样本的a、b和s2024，那么首先我们就可以构造出上面的递推矩阵：
$$
L
=
\left(
 \begin{matrix}
   &1&&&&&\\
   &&1&&&&\\
   &&&1&&&\\
   &&&&\ddots&&\\
   &&&&&1&\\
   a_0&a_1&a_2&a_3&\cdots&a_9&b\\
   &&&&&&1\\
  \end{matrix}
  \right)
  ^{2024}
$$
那么上面的式子可以简化写为：
$$
S_{2024} = LS_{0}
$$
转置一下就得到：
$$
S_0^TL^T = S_{2024}^T
$$
那么此时我们就拥有了一个关系式为：
$$
(s_0,s_1,...,s_9,1)L^T = (s_{2024},s_{2025},...,s_{2033},1) \quad(mod\;p)
$$
由于我们只有最终状态的第一个量，也就是s2024，因此我们也只取L^T的第一列作为线性关系(当然最后一列的1也可以取上)，就得到：
$$
(s_0,s_1,...,s_9,1)L^T_{1} = (s_{2024}) \quad(mod\;p)
$$
那么就可以造出格M：
$$
M 
=
\left(
 \begin{matrix}
   E & L_1^T \\
   O & s_{2024} \\
   O & p
  \end{matrix}
  \right)
$$
其中E是单位阵，O是0矩阵，这个格就具有线性关系：
$$
(s_0,s_1,...,s_9,1,-1,k)
\left(
 \begin{matrix}
   E & L_1^T \\
   O & s_{2024} \\
   O & p
  \end{matrix}
  \right)
 =
 (s_0,s_1,...,s_9,1,0)
$$
配上大系数保证最后一列规约出0，然后检查规约出的向量前面是不是都在可见字符范围内，就可以完成该样本是不是MRG的判定了。由于格的维数并不大，所以判定完所有bit也花不了多长时间。

exp：

```python
from Crypto.Util.number import *
from tqdm import *

#matrix of MRG
def build_iter_Matrix(a,b,p,length):
    L = Matrix(Zmod(p),length+1,length+1)
    for i in range(length-1):
        L[i,i+1] = 1
    for i in range(length):
        L[length-1,i] = a[i]
    L[length-1,-1] = b
    L[-1,-1] = 1

    return L

Round = 2024
A_len = 10
leak_len = 1
p = 
output = 

flag = ""
for i in tqdm(output):
    a,b,s = i[0],i[1],[i[2]]
    L = build_iter_Matrix(a,b,p,A_len)
    L = L^Round
    L = (L.T)[:,:leak_len]
    T = block_matrix(
        [
            [identity_matrix(A_len+1+1),Matrix(ZZ,L).stack(-vector(ZZ,s))],
            [zero_matrix(leak_len,A_len+1+1),identity_matrix(leak_len)*p]
        ]
    )
    Q = diagonal_matrix([1]*(A_len+1+1) + [2^1000]*leak_len)
    T = T*Q
    T = T.LLL()
    T = T/Q
    res = T[0]
    if(abs(res[0]) < 128):
        flag += "0"
    else:
        flag += "1"

print(long_to_bytes(int(flag,2)))


#NSSCTF{D3c1s1on_MRG_I5n'7_diFFiCulT_R1GHT?}
```

