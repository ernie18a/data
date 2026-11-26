Calculation: Trend = SuperTrend(ATR length, ATR multiplier) direction
Calculation: BreakoutLevel = held value, set at each bar where Trend changes from down to up, of maximum of high[i] for i = 1 to swing lookback, stopping before the first i where Trend[i] = up
Calculation: HighEMA = EMA(high, band EMA length)
Calculation: LowEMA = EMA(low, band EMA length)
Calculation: Extension = (close - HighEMA) / (HighEMA - LowEMA) if HighEMA > LowEMA, else 0
Calculation: RelStrength = (close - MA(close, RS MA length, RS MA type)) / MA(close, RS MA length, RS MA type) - (index close - MA(index close, RS MA length, RS MA type)) / MA(index close, RS MA length, RS MA type)
Calculation: BreakoutEntry = close > BreakoutLevel AND close[1] <= BreakoutLevel AND Trend = up AND (RS filter switch off OR RelStrength > RS minimum) AND BreakoutEntry did not occur on any earlier bar since the latest of: Trend changed from down to up, or exit
Calculation: BandEntry = close crosses above HighEMA AND Trend = up AND (RS filter switch off OR RelStrength > RS minimum) AND BandEntry did not occur on any earlier bar since the latest of: close crosses below LowEMA, Extension >= re-arm multiplier, or exit
Calculation: CrossEntry = EMA(close, shorter EMA length) crosses above EMA(close, longer EMA length) AND (bullish-only switch off OR Trend = up) AND (RS filter switch off OR RelStrength > RS minimum)
Long: BreakoutEntry
Long: BandEntry
Long: CrossEntry
Long: (BreakoutEntry OR BandEntry OR CrossEntry) AND at least two of BreakoutEntry, BandEntry, and CrossEntry occurred within the last confluence window bars, including the current bar
Exit: long, RelStrength < RS minimum