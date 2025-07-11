## r3tauq

+   **Difficulty**: Easy
+   **Solved**: 9

<br/>

## Description

As r3girl ventures deeper into the Crypto Block, she discovers an area operating under bewilderingly complex rules. The very essence of this space feels… different, almost alien. The familiar tools and understandings of the cyber-metropolis seem inadequate here.

**"Too quat 4 me,"** she hears someone whisper, sobbing softly.

<br/>

## Solution

This is a very straightforward quaternion problem. The process is as follows:

+   Generate five 256-bit random prime numbers $p, q, r, x, y$, and left-shift $x, y$ by 128 bits. Let $n=pq$.
+   Generate a secret string of length 77, consisting of uppercase and lowercase letters.
+   Generate a quaternion algebra over $Z_n$ that satisfies $\mathbf{i}^2=-x$ and $\mathbf{j}^2=-y$.
+   Let $\mathbf{g} = (x+y) + (p+x)\mathbf{i} + (q+y)\mathbf{j} + r\mathbf{k}$. Calculate $\mathbf{g}' = \mathbf{g}^{s}$, where $s$ is the large integer corresponding to the secret string repeated 777 times.

Given $n, \mathbf{g}'$, you need to find the `secret` to decrypt an AES key and get the flag.

<br/>

### Part 1: Recovering $\mathbf{g}$

Solving for $s$ appears to be a quaternion discrete logarithm problem (DLP). However, for a DLP, the initial state $\mathbf{g}$ is missing, so we must first find a way to recover $\mathbf{g}$. Referring to [this problem](https://blog.wm-team.cn/index.php/archives/80/#RSA), we know that the power recurrence of quaternions has the following property:
$$
\begin{cases} a_n = \displaystyle\sum_{i = 0}^{\lfloor\frac{n}{2}\rfloor} {n \choose n - 2i} \cdot a^{n - 2i} S^i \\ b_n = b X \\ c_n = c X \\ d_n = d X \end{cases} \quad , \quad \begin{cases} S = -(b^2\mathbf{i}^2 + c^2\mathbf{j}^2 + d^2\mathbf{k}^2) \\ X = \sum_{i = 0}^{\lfloor\frac{n - 1}{2}\rfloor} {n \choose n - 2i - 1} \cdot a^{n - 2i - 1} S^i \end{cases}
$$
Here, we mainly use the recurrence for $b_n, c_n, d_n$. As you can see, their recurrence is just the initial state multiplied by the same coefficient $X$. Therefore, we can construct the equation:
$$
\frac{b}{b_n} = \frac{c}{c_n} = \frac{d}{d_n}
$$
Since the modulus $n$ is 512 bits, and the initial coefficients $b=p+x, c=q+y, d=r$ are all relatively small, we can use LLL to recover them. The bound is a bit tight, but it can be solved by brute-forcing a few bits. At this point, we have recovered the last three components of the initial state $\mathbf{g}$: $p+x, q+y, r$.

<br/>

### Part 2: Recovering $p, q, x, y$

With $p+x, q+y$, and $n=pq$, this is a classic problem of p's low bits being leaked. Since $x$ and $y$ are both left-shifted by 128 bits, exactly half of the bits are leaked. We still need to brute-force a few bits. Then, we can factor the modulus $n$ to get $p,q$, and naturally, we also get $x,y$.

<br/>

### Part 3: Recovering $s$

After obtaining $\mathbf{g}$, the problem transforms completely into a quaternion DLP. For a quaternion $a + b\mathbf{i} + c\mathbf{j} + d\mathbf{k}$ in this quaternion algebra, it can be mapped to the following matrix:
$$
M =
\left(\begin{matrix}
a & -bx & -cy & -dxy \\
b & a & -dy & cy \\
c & dx & a & -bx \\
d & -c & b & a \\
\end{matrix}\right)
$$

Therefore, we can map $\mathbf{g}$ and $\mathbf{g}'$ to matrices $L$ and $L^s$ respectively. The quaternion DLP now becomes a matrix DLP.

Since the data chosen for this problem happens to not have eigenvalues in the prime fields $GF(p), GF(q)$, we cannot use Jordan normal form to convert the problem into solving a system of equations. A simple approach is to use the matrix determinant to transform the problem into a DLP in the multiplicative groups of $GF(p)$ and $GF(q)$. Since $p,q$ are 256-bit primes, we need to use the Cado-NFS algorithm to find $s \pmod{p-1}$ and $s \pmod{q-1}$ and then combine them using the Chinese Remainder Theorem (CRT). This allows us to recover a little over 500 bits of information about $s$.

> One could also use partial smooth factors over extension fields to increase the number of bits of information that can be obtained.

<br/>

### Part 4: Recovering the secret

Since the secret is a string composed of uppercase and lowercase letters, we can perform some linear processing to reduce the mean value of all characters. Finally, we can use lattice reduction to find the secret.

<br/>

## Something else

The name of the challenge looks strange. This is because to follow the team's naming convention, "quater" was reversed, which coincidentally became "r3tauq" containing "r3" :3