## easy_MTP1

+ Difficulty：Easy

## Solution

预期做法很简单，由于mask内所有字符都是不可见的，其MSB一定为1，所以flag的每一bit异或1的概率会大于异或0的概率，因此直接逐bit做统计即可。

exp：

```python
from Crypto.Util.number import *
import ast

with open(r"MTP\output.txt","r") as f:
    out = ast.literal_eval(f.read())

length = 2024
def convert_to_bin(msg):
    return bin(bytes_to_long(msg))[2:].zfill(8*length)

rounds = 2024
binlist = []
for i in range(rounds):
    binlist.append(convert_to_bin(out[i]))

flag = ""
for i in range(8*length):
    count0 = 0
    count1 = 0
    for j in range(rounds):
        if(binlist[j][i] == "0"):
            count0 += 1
        else:
            count1 += 1
    if(count0 > count1):
        flag += "1"
    else:
        flag += "0"

print(long_to_bytes(int(flag,2)))

#NSSCTF{M4k3_Us3_0f_M7P_though_M4sK_1s_Non_Printable}
```

