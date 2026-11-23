Calculation: ImpulseBar = (high - low) > ATR(high, low, close, ATR lookback) * ATR multiplier AND abs(close - open) > body strength * (high - low)
Calculation: RecentSwingHighs = the last zone history lookback non-NA values of PivotHigh(high, swing lookback, swing lookback) as of the current bar, index 0 = most recent
Calculation: RecentSwingLows = the last zone history lookback non-NA values of PivotLow(low, swing lookback, swing lookback) as of the current bar, index 0 = most recent
Long: close > SMA(close, SMA lookback)
Long: close > open AND ImpulseBar
Long: low > high[2]
Long: close crosses above EMA(close, EMA lookback, T1, last completed bar)
Long: PivotHigh(high, swing lookback, swing lookback) >= RecentSwingHighs[1]
Long: PivotLow(low, swing lookback, swing lookback) >= RecentSwingLows[1]
Long: close crosses above any of RecentSwingHighs
Short: close < SMA(close, SMA lookback)
Short: close < open AND ImpulseBar
Short: high < low[2]
Short: close crosses below EMA(close, EMA lookback, T1, last completed bar)
Short: PivotHigh(high, swing lookback, swing lookback) < RecentSwingHighs[1]
Short: PivotLow(low, swing lookback, swing lookback) < RecentSwingLows[1]
Short: close crosses below any of RecentSwingLows