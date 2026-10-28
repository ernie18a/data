Calculation: Mean = recursively smoothed close with alpha 2 × min(lowest rolling standard deviation of ATR divided by current rolling standard deviation of ATR, 5) / (EMA lookback + 1), initialized with the EMA-lookback simple average
Calculation: Mean Deviation Index = close minus Mean, with one ATR subtracted from positive deviations and added to negative deviations; clip positive results at zero from below and negative results at zero from above
Long: Mean Deviation Index crosses above 0
Short: Mean Deviation Index crosses below 0