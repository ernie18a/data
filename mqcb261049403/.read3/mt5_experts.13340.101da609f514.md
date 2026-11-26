Calculation: M[n] = zero-lag momentum OSMA(applied price, two independent smoothing lookbacks, five momentum lookbacks ordered shortest to longest with separate corresponding weights, T1 bar n bars ago; n is the signal offset (forming at n = 0, completed at n > 0), evaluated on each new T1 bar
Long: long entries enabled AND M[n] > M[n+1] AND M[n+1] < M[n+2]
Short: short entries enabled AND M[n] < M[n+1] AND M[n+1] > M[n+2]
Exit: short, short exits enabled AND M[n] > M[n+1] AND (long entries disabled OR M[n+1] >= M[n+2])
Exit: long, long exits enabled AND M[n] < M[n+1] AND (short entries disabled OR M[n+1] <= M[n+2])