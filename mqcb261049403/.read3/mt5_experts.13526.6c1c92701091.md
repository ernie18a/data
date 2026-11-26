Calculation: M[n] = MovingAverage(close, lookback, T1, bar n bars ago), evaluated on T1 bars using completed bars
Long: M[0] > M[1]
Short: M[0] < M[1]
Long: M[1] < M[2] AND M[0] > M[1]
Short: M[1] > M[2] AND M[0] < M[1]
Exit: short, M[1] < M[2] AND M[0] <= M[1]
Exit: long, M[1] > M[2] AND M[0] >= M[1]