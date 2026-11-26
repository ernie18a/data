Calculation: W = factor 1 × RSI(applied price, RSI lookback 1) + factor 2 × RSI(applied price, RSI lookback 2) + factor 2 × RSI(applied price, RSI lookback 3) + factor 4 × RSI(applied price, RSI lookback 4) + factor 5 × RSI(applied price, RSI lookback 5)
Calculation: Z = SMMA(W - SMMA(W, smoothing lookback 1), smoothing lookback 2)
Long: Z > 0
Short: Z < 0
Long: Z on T1 bars, using the still-forming T1 bar mapped onto chart bars, > 0
Short: Z on T1 bars, using the still-forming T1 bar mapped onto chart bars, < 0