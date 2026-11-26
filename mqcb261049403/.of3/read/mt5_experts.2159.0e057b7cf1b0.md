Calculation: H[n] = MACD histogram(applied price, n completed T1 bars ago)
Calculation: S[n] = MACD signal line(H, signal smoothing method, signal lookback, signal phase, n completed T1 bars ago on T1 bars)
Long: H[0] > 0
Short: H[0] < 0
Long: H[0] > S[1]
Short: H[0] < S[1]
Long: H[0] > 0 AND H[1] <= 0 AND long entries enabled
Short: H[0] < 0 AND H[1] >= 0 AND short entries enabled
Long: H[1] < H[0] AND H[2] > H[1] AND long entries enabled
Short: H[1] > H[0] AND H[2] < H[1] AND short entries enabled
Long: S[1] < S[0] AND S[2] > S[1] AND long entries enabled
Short: S[1] > S[0] AND S[2] < S[1] AND short entries enabled
Long: H[0] > S[0] AND H[1] <= S[1] AND long entries enabled
Short: H[0] < S[0] AND H[1] >= S[1] AND short entries enabled
Exit: Long, H[0] < 0 AND H[1] >= 0 AND long exits enabled
Exit: Long, H[1] > H[0] AND H[2] < H[1] AND long exits enabled
Exit: Long, S[1] > S[0] AND S[2] < S[1] AND long exits enabled
Exit: Long, H[0] < S[0] AND H[1] >= S[1] AND long exits enabled
Exit: Short, H[0] > 0 AND H[1] <= 0 AND short exits enabled
Exit: Short, H[1] < H[0] AND H[2] > H[1] AND short exits enabled
Exit: Short, S[1] < S[0] AND S[2] > S[1] AND short exits enabled
Exit: Short, H[0] > S[0] AND H[1] <= S[1] AND short exits enabled