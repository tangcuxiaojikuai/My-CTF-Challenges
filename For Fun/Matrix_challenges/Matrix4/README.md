## Matrix4

+ Difficulty：Middle

## Solution

与Matrix2很相似，只是这一次L和R变成了：
$$
L = (\textbf{m}, \textbf{v}_1, \textbf{v}_2, ..., \textbf{v}_{n-1})
$$

$$
R = (s_0\textbf{m}, s_1\textbf{v}_1, s_2\textbf{v}_2, ..., s_{n-1}\textbf{v}_{n-1})
$$

其中si依然是模p下未知的随机数，然后计算：
$$
C = (RL^{-1})^e
$$
给出p、C，要求还原明文。

仍然令：
$$
A = RL^{-1}
$$
我们知道A的其中一个特征向量就是m，而又因为：
$$
C = A^e
$$
由Matrix2中的推导可知，C的特征向量就是A的特征向量，因此我们求C的特征向量，其中有一个应该就是m了。

然而我们会遇到一个问题就是，虽然有：
$$
C \textbf{m} = s_0 \textbf{m}
$$
但是也有：
$$
C (k\textbf{m}) = s_0 (k\textbf{m})
$$
也就是特征向量的任意倍数（非0）也是特征向量，而我们直接用sage求出来的也确实是k倍的m，而不是原向量。

但是由于m较小，所以现在正好转化成了warm_up的相同的问题，因此只需要对求出来的特征向量逐个尝试规约就行。

exp：

```python
from Crypto.Util.number import *

############################################################################################### data
p = 
C = 


############################################################################################### exp
########################################## part1 to mat
n = int(pow(len(C),1/2))
C = Matrix(GF(p), n, n, C)

########################################## part2 find eigenvectors
L = []
res = C.eigenvectors_right()
for i in res:
    eigenvalue = i[0]
    eigenvector = i[1][0]
    L = block_matrix(ZZ,[
        [Matrix(ZZ,eigenvector)],
        [p]
    ])
    res = L.LLL()[1]
    if(abs(res[0]) < 128):
        for i in res:
            print(chr(abs(i)),end="")
        break


#NSSCTF{AnotHer_S1mPl3_EIGeNVecT0Rs_tr1ck!}
```

