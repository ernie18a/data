Calculation: Accumulation boundaries = highest high and lowest low from the first chart bar through the bar accumulation-lookback chart bars later in each T1 interval, held until breakout
Calculation: ATR trailing stop = at an upper-boundary breakout, close − ATR(ATR lookback) × multiplier; at a lower-boundary breakout, close + ATR(ATR lookback) × multiplier; while active in a long direction, max(previous stop, close − ATR(ATR lookback) × multiplier); while active in a short direction, min(previous stop, close + ATR(ATR lookback) × multiplier); test before each bar's update and reset to close ± ATR(ATR lookback) × multiplier on a direction reversal
Long: on a confirmed chart bar before breakout in the current T1 interval, close > upper accumulation boundary
Short: on a confirmed chart bar before breakout in the current T1 interval, close < lower accumulation boundary
Long: after a lower-boundary breakout and before its first stop breach, close > ATR trailing stop
Short: after an upper-boundary breakout and before its first stop breach, close < ATR trailing stop
Exit: long, after a lower-boundary breakout and its first stop breach, close < ATR trailing stop
Exit: short, after an upper-boundary breakout and its first stop breach, close > ATR trailing stop