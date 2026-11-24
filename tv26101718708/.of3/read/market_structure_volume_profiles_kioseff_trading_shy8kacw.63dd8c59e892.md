Calculation: Reach = ATR(high, low, close, atr length, T1, last completed bar) * atr multiplier
Calculation: Leg = on the first chart bar, Up if high >= close + Reach, otherwise Down; afterwards, Up if UpReversal, Down if DownReversal, otherwise Leg[1]
Calculation: Extreme = on the first chart bar, high if Leg = Up, otherwise low; afterwards, high if UpReversal, low if DownReversal, max(Extreme[1], high) if Leg = Up, otherwise min(Extreme[1], low)
Calculation: LastHigh = on the first chart bar, close if Leg = Down, otherwise na; afterwards, Extreme[1] if DownReversal, otherwise LastHigh[1]
Calculation: LastLow = on the first chart bar, close if Leg = Up, otherwise na; afterwards, Extreme[1] if UpReversal, otherwise LastLow[1]
Calculation: UpReversal = Leg[1] = Down AND low > Extreme[1] AND high >= Extreme[1] + Reach + buffer * |Extreme[1] - LastHigh[1]|
Calculation: DownReversal = Leg[1] = Up AND high < Extreme[1] AND low <= Extreme[1] - Reach - buffer * |Extreme[1] - LastLow[1]|
Calculation: UpBreak = (Leg[1] = Up AND close[1] <= LastHigh[1] AND close > LastHigh[1] AND LastHigh[1] != BreakLevel[1] AND (Structure[1] = Down OR bar is last chart bar of T1)) OR (UpReversal AND close > LastHigh[1] AND LastHigh[1] != BreakLevel[1] AND bar is last chart bar of T1)
Calculation: DownBreak = (Leg[1] = Down AND close[1] > LastLow[1] AND close <= LastLow[1] AND LastLow[1] != BreakLevel[1] AND bar is last chart bar of T1) OR (DownReversal AND close < LastLow[1] AND LastLow[1] != BreakLevel[1] AND bar is last chart bar of T1)
Calculation: BreakLevel = LastHigh[1] if UpBreak, LastLow[1] if DownBreak, otherwise BreakLevel[1]; none initially
Calculation: Structure = Up if UpBreak, Down if DownBreak, otherwise Structure[1]; on the first chart bar, Leg
Calculation: BarDelta = sum over T0 bars within the current bar of volume * sign(close - close of the previous T0 bar)
Long: UpBreak = true
Short: DownBreak = true
Long: Structure = Up
Short: Structure = Down
Long: BarDelta >= 0
Short: BarDelta < 0