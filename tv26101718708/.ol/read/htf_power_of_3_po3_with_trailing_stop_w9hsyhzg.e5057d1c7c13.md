Calculation: Accumulation upper/lower boundary = highest high / lowest low among chart-timeframe bars from the first bar of the current higher-timeframe session through its first N subsequent bars, including the session open in both boundaries; keep fixed thereafter. The higher-timeframe session is still forming.
Calculation: Trailing stop = for an upward direction, the greater of the prior stop and current close minus ATR × multiplier; for a downward direction, the lesser of the prior stop and current close plus ATR × multiplier. Initialize it at the breakout close adjusted by ATR × multiplier. ATR uses chart-timeframe bars.
Long: confirmed close > accumulation upper boundary before any breakout in the current higher-timeframe session OR close > trailing stop after a downward accumulation breakout and before the first trailing-stop breach
Long: close > trailing stop after an upward accumulation breakout has changed to downward distribution
Short: confirmed close < accumulation lower boundary before any breakout in the current higher-timeframe session OR close < trailing stop after an upward accumulation breakout and before the first trailing-stop breach
Short: close < trailing stop after a downward accumulation breakout has changed to upward distribution
Exit: long, close < trailing stop
Exit: short, close > trailing stop