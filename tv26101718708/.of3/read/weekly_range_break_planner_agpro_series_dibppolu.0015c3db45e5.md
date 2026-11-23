Calculation: Range = High(T1, last completed bar) - Low(T1, last completed bar)
Calculation: BreakSide = +1 or -1 for the first chart bar of the still-forming T1 bar, up to this bar, with Range >= min range * ATR(ATR length) and close above High(T1, last completed bar) + break buffer * ATR(ATR length) (+1) or close below Low(T1, last completed bar) - break buffer * ATR(ATR length) (-1); 0 if no such bar
Calculation: BreakAge = bars since the first chart bar of the still-forming T1 bar on which BreakSide != 0
Calculation: Edge = High(T1, last completed bar) if BreakSide = +1, Low(T1, last completed bar) if BreakSide = -1
Calculation: Stop = Edge - BreakSide * invalidation buffer * ATR(ATR length)
Calculation: Invalid = close < Stop if BreakSide = +1, close > Stop if BreakSide = -1
Calculation: Tested = high >= Edge - shelf depth * ATR(ATR length) AND low <= Edge + shelf depth * ATR(ATR length)
Calculation: Holds = Tested AND BreakSide * (close - Edge) >= 0
Calculation: Distance = abs(close - Edge) / ATR(ATR length)
Calculation: Target = Edge + BreakSide * Range * target multiple
Calculation: Score = clamp(range weight * clamp(Range / (range scale * ATR(ATR length)), 0, 1) + close weight * clamp(Distance / close scale, 0, 1) + (holds weight if Holds, else tested weight if Tested, else untested weight) + (time weight * clamp(1 - BreakAge / window, 0, 1) if BreakAge >= 1, else 0) + (volume weight * clamp(volume / SMA(volume, volume length) / volume scale, 0, 1) if use volume, else no-volume weight) + room weight * clamp(BreakSide * (Target - close) / (room scale * ATR(ATR length)), 0, 1), 0, 100)
Calculation: Ready = BreakSide != 0 AND Score >= minimum score - confirmation offset AND (Holds OR Distance >= ready distance) AND NOT Invalid
Calculation: Settled = Ready OR Invalid on any earlier chart bar of the still-forming T1 bar
Long: BreakSide = +1 AND BreakAge <= window + 1 AND Ready AND NOT Settled
Short: BreakSide = -1 AND BreakAge <= window + 1 AND Ready AND NOT Settled
Exit: long, bars since entry >= 1 AND (high >= Target at entry bar OR close < Stop at entry bar OR bars since entry > window)
Exit: short, bars since entry >= 1 AND (low <= Target at entry bar OR close > Stop at entry bar OR bars since entry > window)