Calculation: TRAX = 10,000 × the one-bar change in the triple-smoothed VWMA of log(close), using the same lookback for all three VWMA calculations
Calculation: DPO = close from floor(DPO lookback / 2) + 1 bars ago − SMA(close, DPO lookback)
Long: DPO > TRAX AND previous DPO ≤ previous TRAX AND TRAX < 0 AND close > SMA(close, confirmation lookback)
Short: DPO < TRAX AND previous DPO ≥ previous TRAX AND TRAX > 0 AND close < SMA(close, confirmation lookback)