Calculation: BoundaryPad = ATR(ATR length) * ATR padding multiplier + StDev(close, rail length) / volatility scale
Calculation: UpperBoundary = EMA(Highest(high, rail length) + BoundaryPad, rail smoothing length)
Calculation: LowerBoundary = EMA(Lowest(low, rail length) - BoundaryPad, rail smoothing length)
Calculation: UpwardBreak = close > UpperBoundary[1] AND close > open AND ABS(close - open) >= displacement multiple * ATR(ATR length)[1] AND volume >= relative volume multiple * SMA(volume, volume average length)[1]
Calculation: DownwardBreak = close < LowerBoundary[1] AND close < open AND ABS(close - open) >= displacement multiple * ATR(ATR length)[1] AND volume >= relative volume multiple * SMA(volume, volume average length)[1]
Calculation: EpisodeState = 1 if UpwardBreak, -1 if DownwardBreak, 0 if LowerBoundary[1] <= close <= UpperBoundary[1], otherwise EpisodeState[1]
Long: UpwardBreak AND EpisodeState[1] <> 1
Short: DownwardBreak AND EpisodeState[1] <> -1