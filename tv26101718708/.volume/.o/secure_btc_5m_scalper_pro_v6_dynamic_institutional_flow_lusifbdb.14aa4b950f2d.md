Calculation: Bullish-candle share = percentage of bars in its lookback with close > open.
Calculation: Bullish structure = the highest high and lowest low of the recent short lookback are each >= the corresponding extreme in the preceding longer lookback.
Calculation: Bearish structure = the highest high and lowest low of the recent short lookback are each <= the corresponding extreme in the preceding longer lookback.
Calculation: Volume delta = sum over its lookback of volume × ((close − low) − (high − close)) / (high − low); use 1 for a zero range or missing volume.
Calculation: VWAP distance = percentage difference between close and current-session VWAP.
Long: On the current bar, previous completed bar close crosses above Supertrend AND that close is above EMA AND previous completed bar RSI is above its midpoint AND previous completed bar ADX is above its threshold
Long: Bullish-candle share on the bar still forming is above its upper threshold
Long: Bullish structure on the bar still forming
Long: Volume delta on the bar still forming is above its positive threshold
Long: VWAP distance on the bar still forming is above its positive threshold
Short: On the current bar, previous completed bar close crosses below Supertrend AND that close is below EMA AND previous completed bar RSI is below its midpoint AND previous completed bar ADX is above its threshold
Short: Bullish-candle share on the bar still forming is below its lower threshold
Short: Bearish structure on the bar still forming
Short: Volume delta on the bar still forming is below its negative threshold
Short: VWAP distance on the bar still forming is below its negative threshold