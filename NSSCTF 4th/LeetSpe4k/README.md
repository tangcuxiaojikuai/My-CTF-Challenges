## LeetSpe4k

+ Difficulty：Easy
+ Solved：0

<br/>

## Description

LeetSpe4k!

<br/>

## Solution

题目的hash函数实际上是fnv类函数，每一字符的leet表可利用来规约对应的01向量，利用仿射子空间对每个字符均降一维即可规约出对应的01向量从而恢复flag。
