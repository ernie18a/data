Calculation: Direction = 1 if Momentum(close, lookback) > move threshold * ATR(ATR length); else -1 if Momentum(close, lookback) < -move threshold * ATR(ATR length); else 1 if EMA(close, shorter trend lookback) > EMA(close, longer trend lookback); else -1 if EMA(close, shorter trend lookback) < EMA(close, longer trend lookback); else 0
Calculation: Consistency = 100 * (count of k in 0..lookback-1 where (Direction[k] > 0 AND close[k] > close[k+1]) OR (Direction[k] < 0 AND close[k] < close[k+1])) / lookback
Calculation: Relative Volume = clamp(volume / SMA(volume, lookback) * volume scale, 0, 100)
Calculation: Relative Range = clamp((high - low) / SMA(high - low, lookback) * range scale, 0, 100)
Calculation: Strength = clamp(Consistency * consistency weight + Relative Volume * volume weight + Relative Range * range weight + 100 * Efficiency Ratio(close, lookback) * efficiency weight, 0, 100)
Calculation: Extension = clamp(abs(close - EMA(close, longer trend lookback)) / ATR(ATR length) * extension scale, 0, 100)
Calculation: Wick Pressure = 100 * (high - max(open, close)) / (high - low) if Direction > 0; else 100 * (min(open, close) - low) / (high - low) if Direction < 0; else neutral wick pressure
Calculation: Volume Fade = clamp(Relative Volume[1] - Relative Volume + volume fade offset, 0, 100) if Relative Volume < Relative Volume[1]; else 0
Calculation: Exhaustion Risk = clamp(Extension * extension weight + (100 - Strength) * strength fade weight + Wick Pressure * wick weight + Volume Fade * volume fade weight, 0, 100)
Calculation: Exhaustion Hit = Direction != 0 AND Exhaustion Risk >= exhaustion threshold AND Strength < hit strength ceiling
Calculation: Hit Onset = Exhaustion Hit AND NOT Exhaustion Hit[1]
Calculation: Fuel Active = Direction != 0 AND Strength >= fade threshold AND Exhaustion Risk < exhaustion threshold
Calculation: Fuel Active Onset = Fuel Active AND NOT Fuel Active[1]
Calculation: Bars Since Onset = BarsSince(Hit Onset)
Calculation: Onset Direction = ValueWhen(Hit Onset, Direction, 0)
Calculation: Race Upper = ValueWhen(Hit Onset, close, 0) + reaction target * ValueWhen(Hit Onset, ATR(ATR length), 0)
Calculation: Race Lower = ValueWhen(Hit Onset, close, 0) - reaction target * ValueWhen(Hit Onset, ATR(ATR length), 0)
Long: Direction > 0 AND Fuel Active Onset
Long: Onset Direction < 0 AND Bars Since Onset >= 1 AND Bars Since Onset <= reaction window AND high >= Race Upper AND low > Race Lower AND Highest(high[1], Bars Since Onset - 1) < Race Upper AND Lowest(low[1], Bars Since Onset - 1) > Race Lower
Short: Direction < 0 AND Fuel Active Onset
Short: Onset Direction > 0 AND Bars Since Onset >= 1 AND Bars Since Onset <= reaction window AND low <= Race Lower AND high < Race Upper AND Highest(high[1], Bars Since Onset - 1) < Race Upper AND Lowest(low[1], Bars Since Onset - 1) > Race Lower
Exit: long, Direction > 0 AND Hit Onset
Exit: short, Direction < 0 AND Hit Onset