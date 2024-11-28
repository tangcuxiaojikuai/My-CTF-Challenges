## [密码签到] Signin

+ Difficulty：Baby
+ Solved：74

<br/>

## Description

Bear heard sth like 'Caesar'?

<br/>

## Hint

我们找到了熊的加密代码！！ 

```python
print("".join([hex((flag[i] + 3) % 256)[2:].zfill(2) for i in range(len(flag))]))
```

<br/>

## Solution

题目描述里明确指出是凯撒，所以先解一下十六进制可以发现和已知的flag头"catctf"ASCII码差了3，所以再移位回去就好。生成密文脚本为：

```python
from secret import flag

print("".join([hex((flag[i] + 3) % 256)[2:].zfill(2) for i in range(len(flag))]))
```

exp：

```python
c = "6664776677697e583834714a62537536496c7b62666477667769623a33624934716762733777687551766272696246646876647580"
c = bytes.fromhex(c)

print("".join([chr((c[i] - 3) % 256) for i in range(len(c))]).encode())


#catctf{U51nG_Pr3Fix_catctf_70_F1nd_p4terNs_of_Caesar}
```
