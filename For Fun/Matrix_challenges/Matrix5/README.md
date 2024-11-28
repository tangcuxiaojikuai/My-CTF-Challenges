## Matrix5

+ Difficulty：Middle

## Solution

本题仍然基于特征向量和特征值，这一次L、R变成：
$$
L = (\textbf{v}_1 | \textbf{m}_{:5}, \textbf{v}_2 | \textbf{m}_{1:6}, ... ,\textbf{v}_n | \textbf{m}_{n-5:n})
$$

$$
R = (s_1(\textbf{v}_1 | \textbf{m}_{:5}), s_2(\textbf{v}_2 | \textbf{m}_{1:6}), ... ,s_3(\textbf{v}_n | \textbf{m}_{n-5:n}))
$$

仍然记：
$$
A = RL^{-1}
$$

$$
C = A^e
$$

对于本题的C来说，题意在于他的每一个特征向量的某个k倍，其最后五个值会是flag的片段。

我们不妨记我们直接求出的某个特征向量为$\textbf{l}$，那么就有：
$$
\textbf{l} = k(\textbf{v}_i | \textbf{m}_{i:i+5})
$$
其中k我们并不知道，vi中的值是模p下的随机量，只有最后五个值，也就是m的片段在模p下才是小量，所以我们也取$\textbf{l}$的最后五维向量片段，仍然做warm_up的规约，就可以得到所有片段了。

此时得到的明文片段是无序的，然而由于相邻的片段会有四个字符的重合，所以从已知的flag头"NSSC"出发检查所有片段的重合字符数量就可以还原flag。

exp：

```python
from Crypto.Util.number import *

############################################################################################### data


############################################################################################### exp
########################################## part1 to mat
n = int(pow(len(C),1/2))
def to_mat(M):
    mat = []
    for i in range(n):
        temp = []
        for j in range(n):
            temp.append(M[n*i+j])
        mat.append(temp)
    return Matrix(Zmod(p), mat)
C = Matrix(GF(p),to_mat(C))

########################################## part2 find eigenvectors
L = []
res = C.eigenvectors_right()
flag_pad = []
for i in res:
    eigenvalue = i[0]
    eigenvector = i[1][0]
    L = block_matrix(ZZ,[
        [Matrix(ZZ,eigenvector[-5:])],
        [p]
    ])
    res = L.LLL()[1]
    temp = ""
    for i in res:
        temp += chr(abs(i))
    flag_pad.append(temp)

prefix = "NSSC"
flag = "NSSC"
for i in range(n+3):
    for j in flag_pad:
        if(j[:4] == prefix[-4:]):
            flag += j[-1]
            prefix = j
            break
print(flag)


#NSSCTF{U_h4Ve_C0mp1et3d_H@lF_0f_MATRIX_cha1LenGe5!}
```

> 如果特征向量中只有最后一个字符是flag的话，这个方法是做不了的，原因如下：
>
> + 无法还原顺序
>
> + 造出的格是：
>   $$
>   \left(\begin{matrix}
>   t\\
>   p\\
>   \end{matrix}\right)
>   $$
>   一定会有：
>   $$
>   (t^{-1},k)
>   \left(\begin{matrix}
>   t\\
>   p\\
>   \end{matrix}\right)
>   =
>   (1)
>   $$
>   这个向量短于作为字符的mi，所以找不到解
>
> 如果特征向量只有最后两个字符是flag的话，顺序的问题基本得到解决，题目就可以解出了，只是要注意一下下面这一点，也就是格为：
> $$
> \left(\begin{matrix}
> t_1&t_2\\
> p\\
> &p\\
> \end{matrix}\right)
> $$
> 期望的目标向量是：
> $$
> (a,k_1,k_2)
> \left(\begin{matrix}
> t_1&t_2\\
> p\\
> &p\\
> \end{matrix}\right)
> =
> (m_i,m_{i+1})
> $$
> 在两个字符的数值互素时这样当然没有问题，然而如果两个字有最大公约数d，那么找到的解应该是：
> $$
> (\frac{a}{d},k_1',k_2')
> \left(\begin{matrix}
> t_1&t_2\\
> p\\
> &p\\
> \end{matrix}\right)
> =
> (\frac{m_i}{d},\frac{m_{i+1}}{d})
> $$
> 所以找的时候还要小爆一下d才行，但是这个步骤感觉没有什么必要，因此最后是每五个字符作为一个片段，这样基本上就不会有公约数的问题了。

