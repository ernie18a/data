Calculation: CVD = cumulative sum, seeded at zero, of volume × (2 × close − high − low) / (high − low + tick-size parameter)
Calculation: Classifier warm-up = number of labeled training bars ≥ classifier lookback
Long: CVD > CVD[1] OR Classifier warm-up AND close > EMA(close, trend lookback)
Short: CVD ≤ CVD[1] OR Classifier warm-up AND close < EMA(close, trend lookback)