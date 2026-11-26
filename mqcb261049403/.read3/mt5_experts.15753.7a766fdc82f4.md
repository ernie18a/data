Calculation: M = MACD(RSI(close, RSI lookback), shorter MACD lookback, longer MACD lookback), calculated on T1 bars with [0] the last completed bar and [n] the value n completed bars ago
Calculation: S = EMA(M, signal lookback), calculated on T1 bars with [0] the last completed bar and [n] the value n completed bars ago
Long: M[1] > 0 AND M[0] <= 0
Short: M[1] < 0 AND M[0] >= 0
Exit: short, M[1] > 0 AND M[0] > 0
Exit: long, M[1] < 0 AND M[0] < 0
Long: M[1] < M[2] AND M[0] > M[1]
Short: M[1] > M[2] AND M[0] < M[1]
Exit: short, M[1] < M[2] AND M[0] <= M[1]
Exit: long, M[1] > M[2] AND M[0] >= M[1]
Long: S[1] < S[2] AND S[0] > S[1]
Short: S[1] > S[2] AND S[0] < S[1]
Exit: short, S[1] < S[2] AND S[0] <= S[1]
Exit: long, S[1] > S[2] AND S[0] >= S[1]
Long: M[1] > S[1] AND M[0] <= S[0]
Short: M[1] < S[1] AND M[0] >= S[0]
Exit: short, M[1] > S[1] AND M[0] > S[0]
Exit: long, M[1] < S[1] AND M[0] < S[0]