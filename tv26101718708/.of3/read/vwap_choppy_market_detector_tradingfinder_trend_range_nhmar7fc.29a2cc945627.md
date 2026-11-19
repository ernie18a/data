Calculation: Primary bands = VWAP(open, anchor T1, multiplier P1, calculated on chart bars through the current bar and reset at T1 boundaries)
Calculation: Inner bands = VWAP(open, anchor T1, multiplier P2, calculated on chart bars through the current bar and reset at T1 boundaries)
Calculation: Volatility threshold = ATR(lookback P3, chart bars) * P4
Long: Primary upper band != primary lower band AND close > inner upper band AND primary upper band - primary lower band >= volatility threshold
Short: Primary upper band != primary lower band AND close < inner lower band AND primary upper band - primary lower band >= volatility threshold