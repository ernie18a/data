Calculation: Baseline = EMA(EMA(close, baseline lookback), same lookback)
Calculation: Upper and lower bands = Baseline + ATR × band multiplier, and Baseline − ATR × band multiplier
Calculation: Trend regime = bullish after close crosses above the upper band; bearish after close crosses below the lower band; otherwise retain the prior regime
Calculation: Pivot-anchored VWAP = VWAP of low[1] anchored at a qualifying swing-low anchor for bearish signals, or VWAP of high[1] anchored at a qualifying swing-high anchor for bullish signals
Long: Bullish trend regime AND an active bullish pivot-anchored VWAP exists AND close >= bullish pivot-anchored VWAP AND no confirmed pivot high
Short: Bearish trend regime AND an active bearish pivot-anchored VWAP exists AND close <= bearish pivot-anchored VWAP AND no confirmed pivot low