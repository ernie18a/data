Calculation: LastPivotHigh(pivot length) = latest non-na PivotHigh(high, pivot length, pivot length)
Calculation: LastPivotLow(pivot length) = latest non-na PivotLow(low, pivot length, pivot length)
Calculation: BullBreak(pivot length) = first bar on or since the latest PivotHigh(high, pivot length, pivot length) confirmation where close > LastPivotHigh(pivot length) AND close[1] <= LastPivotHigh(pivot length)
Calculation: BearBreak(pivot length) = first bar on or since the latest PivotLow(low, pivot length, pivot length) confirmation where close < LastPivotLow(pivot length) AND close[1] >= LastPivotLow(pivot length)
Calculation: Bias(pivot length) = bullish if the most recent of BullBreak(pivot length) or BearBreak(pivot length) is BullBreak, bearish if it is BearBreak, neutral if neither has occurred
Calculation: MaxPivotHigh(pivot length) = highest PivotHigh(high, pivot length, pivot length) value up to the current bar
Calculation: MinPivotLow(pivot length) = lowest PivotLow(low, pivot length, pivot length) value up to the current bar
Long: BullBreak(swing length)
Short: BearBreak(swing length)
Long: BullBreak(internal length)
Short: BearBreak(internal length)
Long: Bias(swing length) = bullish
Short: Bias(swing length) = bearish
Long: Bias(internal length) = bullish
Short: Bias(internal length) = bearish
Long: BullBreak(swing length) AND close[i] < open[i] for some i from 1 to order block lookback
Short: BearBreak(swing length) AND close[i] > open[i] for some i from 1 to order block lookback
Long: low > high[2] AND low - high[2] >= ATR(atr length) * FVG ATR multiplier
Short: high < low[2] AND low[2] - high >= ATR(atr length) * FVG ATR multiplier
Long: MaxPivotHigh(swing length) > MinPivotLow(swing length) AND close <= MinPivotLow(swing length) + zone fraction * (MaxPivotHigh(swing length) - MinPivotLow(swing length))
Short: MaxPivotHigh(swing length) > MinPivotLow(swing length) AND close >= MaxPivotHigh(swing length) - zone fraction * (MaxPivotHigh(swing length) - MinPivotLow(swing length))
Long: PivotLow(low, swing length, swing length) confirmed on this bar
Short: PivotHigh(high, swing length, swing length) confirmed on this bar
Long: PivotLow(low, swing length, swing length) confirmed on this bar AND ABS(LastPivotLow(swing length) - second-latest PivotLow(low, swing length, swing length)) <= ATR(atr length) * EQ ATR multiplier
Short: PivotHigh(high, swing length, swing length) confirmed on this bar AND ABS(LastPivotHigh(swing length) - second-latest PivotHigh(high, swing length, swing length)) <= ATR(atr length) * EQ ATR multiplier