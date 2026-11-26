Calculation: H = Blau SM Stochastic histogram(applied price parameter, stochastic lookback parameter, first smoothing-length parameter, second smoothing-length parameter, third smoothing-length parameter, smoothing-method parameter, phase parameter, T1 bars, last completed bar)
Calculation: S = smoothing method(H, signal-line smoothing-length parameter, smoothing-method parameter, phase parameter, T1 bars, last completed bar)
Long: H[0] > 0
Short: H[0] < 0
Long: H[0] > S[0]
Short: H[0] < S[0]
Long: selected entry algorithm is zero crossing AND H[1] > 0 AND H[0] <= 0 OR selected entry algorithm is histogram reversal AND H[2] > H[1] AND H[0] > H[1] OR selected entry algorithm is signal-cloud reversal AND H[1] > S[1] AND H[0] <= S[0]
Short: selected entry algorithm is zero crossing AND H[1] < 0 AND H[0] >= 0 OR selected entry algorithm is histogram reversal AND H[2] < H[1] AND H[0] < H[1] OR selected entry algorithm is signal-cloud reversal AND H[1] < S[1] AND H[0] >= S[0]