c = "6664776677697e583834714a62537536496c7b62666477667769623a33624934716762733777687551766272696246646876647580"
c = bytes.fromhex(c)

print("".join([chr((c[i] - 3) % 256) for i in range(len(c))]).encode())


#catctf{U51nG_Pr3Fix_catctf_70_F1nd_p4terNs_of_Caesar}