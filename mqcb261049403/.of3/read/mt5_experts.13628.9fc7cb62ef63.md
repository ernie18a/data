Calculation: M[n] = FineTuningMA(T1)[n] on T1 bars, where [0] is the just-closed bar and [n] counts earlier T1 bars
Long: M[1] < M[2] AND M[0] > M[1]
Short: M[1] > M[2] AND M[0] < M[1]
Exit: short, M[1] < M[2] AND M[0] <= M[1]
Exit: long, M[1] > M[2] AND M[0] >= M[1]