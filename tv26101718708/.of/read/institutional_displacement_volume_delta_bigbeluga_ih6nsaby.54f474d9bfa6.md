Calculation: Body ratio = 0 if high = low; otherwise abs(close - open) / (high - low).
Calculation: Bullish shift = close > open AND volume > simple moving average of volume including the current bar * volume multiplier AND body ratio >= minimum body ratio.
Calculation: Bearish shift = close < open AND volume > simple moving average of volume including the current bar * volume multiplier AND body ratio >= minimum body ratio.
Calculation: Last shift delta = for the most recent bullish or bearish shift, the sum of volume of completed lower-timeframe bars within that shift whose close > open minus the sum of volume of those whose close < open; initialize to 0 before any shift.
Long: Bullish shift.
Short: Bearish shift.
Long: The most recent shift is a bullish shift.
Short: The most recent shift is a bearish shift.
Long: Last shift delta > 0.
Short: Last shift delta <= 0.