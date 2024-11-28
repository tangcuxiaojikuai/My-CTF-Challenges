## Matrix9_v2

+ Difficulty：Middle

## Solution

相比于Matrix9，本题变化为：

+ 回到了256bit的素数域
+ A变成了flag的编码矩阵

而由上题经验我们应该知道A依然是下面矩阵方程的解：
$$
BX = XB
$$
而A又很小，那么思路就很简单了——LLL！

exp：

```python
from Crypto.Util.number import *

############################################################################################### data
p = 
B = 


############################################################################################### exp
########################################## part1 to mat
n = 10
B = Matrix(Zmod(p), n, n, B)


########################################## part2 get solution of BX = XB
L = Matrix(Zmod(p), n^2, n^2)
for i in range(n):
    for j in range(n):
        for t in range(n):
            L[n*i+j, n*i+t] += B[t,j]
            L[n*i+j, j+n*t] -= B[i,t]
T = Matrix(Zmod(p), L.right_kernel().basis())


########################################## part3 LLL
T = block_matrix(ZZ,[
    [T],
    [p]
])
res = T.LLL()[n+1]
for i in res:
    if(abs(i) < 128 and abs(i) > 32):
        print(chr(abs(i)), end="")
    else:
        print("*", end="")

#*SSCTF{St1l*LLL111lllI*I_1n_th3_k*rn3L!}
#NSSCTF{St1llLLL111lllIII_1n_th3_k3rn3L!}
```

