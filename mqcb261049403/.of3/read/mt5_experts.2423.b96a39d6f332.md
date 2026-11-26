Calculation: H[n] = Blau HLM histogram from close using momentum lookback, first, second, and third smoothing lookbacks, signal smoothing lookback, smoothing method, and phase on T1 at offset n; sampled on chart bars (offset zero is the forming T1 bar; positive offsets are completed bars)
Calculation: C1[n], C2[n] = first and second Blau HLM signal-cloud lines with the same inputs and sampling as H[n]
Long: H[n] > 0
Short: H[n] < 0
Long: H[n] > 0 AND H[n+1] <= 0
Short: H[n] < 0 AND H[n+1] >= 0
Exit: Long, H[n] < 0
Exit: Short, H[n] > 0
Long: H[n] > H[n+1] AND H[n+1] < H[n+2]
Short: H[n] < H[n+1] AND H[n+1] > H[n+2]
Exit: Long, H[n] < H[n+1]
Exit: Short, H[n] > H[n+1]
Long: C1[n] > C2[n] AND C1[n+1] <= C2[n+1]
Short: C1[n] < C2[n] AND C1[n+1] >= C2[n+1]
Exit: Long, C1[n] < C2[n]
Exit: Short, C1[n] > C2[n]