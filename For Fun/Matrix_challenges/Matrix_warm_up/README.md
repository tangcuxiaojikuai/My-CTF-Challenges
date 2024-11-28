## Matrix_warm_up

+ Difficulty：Easy

## Solution

题目给出256bit的素数p以及一个模p下的向量c，满足：
$$
\textbf{c} = a \cdot \textbf{m} \quad(mod\;p)
$$

$$
\textbf{m} = (m_0q_0, m_1q_1, ..., m_iq_i)
$$

其中a未知，mi是flag的字符对应数值，qi是随机取的128bit的素数。

突破点显然在于向量m较小，所以用如下格：
$$
\left(\begin{matrix}
c_0&c_1&\cdots&c_i\\
p\\
&p\\
&&\ddots\\
&&&p
\end{matrix}\right)
_{i+1,i}
$$
这个格具有的线性关系是：
$$
(a^{-1},k_0,k_1,...,k_i)
\left(\begin{matrix}
c_0&c_1&\cdots&c_i\\
p\\
&p\\
&&\ddots\\
&&&p
\end{matrix}\right)
_{i+1,i}
=
(m_0q_0, m_1q_1, ..., m_iq_i)
$$
注意到这个格并不是一个方阵，这是因为a的逆元并不是一个模p意义下的小数字，所以我们没有必要规约他。而这种行>列的非方阵格会带来一个问题——格基并不是线性无关的，秩只有i，因此LLL会得到一行全0，故向量m会出现在第二行。

exp：

```python
from Crypto.Util.number import *

p = 
c = 

L = block_matrix(ZZ,[
    [Matrix(ZZ,c)],
    [p]
])
res = L.LLL()[1]

for i in res:
    print(chr(abs(i // factor(i)[-1][0])),end="")


#NSSCTF{F1nd_@_s3cR3t_NUMBER_1s_eAsy_4_U}
```

