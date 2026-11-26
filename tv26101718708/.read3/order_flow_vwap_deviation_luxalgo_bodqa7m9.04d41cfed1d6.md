Calculation: FVG volatility filter = abs(close[1] - open[1]) > SMA(abs(close - open), body lookback) * FVG volatility multiplier
Long: low <= any untriggered historical pivot low (PivotLow(low, left pivot lookback, right pivot lookback)) AND volume > SMA(volume, volume lookback) * stop volume multiplier
Short: high >= any untriggered historical pivot high (PivotHigh(high, left pivot lookback, right pivot lookback)) AND volume > SMA(volume, volume lookback) * stop volume multiplier
Long: close > the upper boundary of an active bearish FVG formed when high < low[2] AND the FVG volatility filter is true
Short: close < the lower boundary of an active bullish FVG formed when low > high[2] AND the FVG volatility filter is true