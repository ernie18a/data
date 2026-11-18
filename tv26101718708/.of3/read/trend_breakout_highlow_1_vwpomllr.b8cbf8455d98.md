Calculation: upper band = on the first chart bar of each new T1 period, the previous completed T1 bar's high − (that high − that low) × (100 − trading-range parameter) / 200; hold until the next T1 period
Calculation: lower band = on the first chart bar of each new T1 period, the previous completed T1 bar's low + (that high − that low) × (100 − trading-range parameter) / 200; hold until the next T1 period
Calculation: long stop = upper band at entry − (upper band at entry − lower band at entry) × stop-range parameter / 100
Calculation: short stop = lower band at entry + (upper band at entry − lower band at entry) × stop-range parameter / 100
Calculation: volatility offset = EMA(TrueRange, ATR lookback) × ATR multiplier, calculated on chart bars
Long: long entries enabled AND flat AND upper band > SMA(close, SMA lookback, T1 bar still forming, mapped to chart bars) AND close > upper band
Short: short entries enabled AND flat AND lower band < SMA(close, SMA lookback, T1 bar still forming, mapped to chart bars) AND close < lower band
Exit: Long, low <= long stop OR high >= close[1] + volatility offset[1]
Exit: Short, high >= short stop OR low <= close[1] − volatility offset[1]