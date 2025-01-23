from Crypto.Util.Padding import pad
from Crypto.Cipher import AES
from secret import flag

key, iv = flag[:16].encode(), b"CatCTF2024"
print("c =", AES.new(key=key,nonce=iv,mode=AES.MODE_CTR).encrypt(pad(flag.encode(),16)) + AES.new(key=key,nonce=iv,mode=AES.MODE_CTR).encrypt(b"".join([pad(i.encode(),16) for i in flag])))