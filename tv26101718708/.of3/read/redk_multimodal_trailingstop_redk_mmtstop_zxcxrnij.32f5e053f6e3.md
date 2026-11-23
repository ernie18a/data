Calculation: StopATR = ATR(ATR length) if HTF ATR is off, else ATR(ATR length, T1)[1] at last completed T1 bar, taken on chart bars
Calculation: LongCandidate = anchor price - StopATR * ATR multiplier if trailing method is ATR/Supertrend; Highest(high, chandelier lookback) - ATR(chandelier ATR length) * chandelier multiplier if trailing method is Chandelier; Lowest(low, donchian lookback) if trailing method is Donchian; anchor price - StdDev(anchor price, StdDev length) * StdDev multiplier if trailing method is StdDev channel; anchor price * (1 - fixed trail % / 100) if trailing method is Fixed %
Calculation: ShortCandidate = anchor price + StopATR * ATR multiplier if trailing method is ATR/Supertrend; Lowest(low, chandelier lookback) + ATR(chandelier ATR length) * chandelier multiplier if trailing method is Chandelier; Highest(high, donchian lookback) if trailing method is Donchian; anchor price + StdDev(anchor price, StdDev length) * StdDev multiplier if trailing method is StdDev channel; anchor price * (1 + fixed trail % / 100) if trailing method is Fixed %
Calculation: LongStop = max(LongCandidate, LongStop[1]) if close[1] > LongStop[1], else LongCandidate
Calculation: ShortStop = min(ShortCandidate, ShortStop[1]) if close[1] < ShortStop[1], else ShortCandidate
Calculation: Direction = 1 if close > ShortStop[1]; -1 if close < LongStop[1]; else Direction[1]
Calculation: TrailStop = LongStop if Direction = 1, else ShortStop
Long: Direction crosses above 0
Short: Direction crosses below 0
Exit: Long, close crosses below TrailStop
Exit: Short, close crosses above TrailStop
Exit: Long, abs(close - TrailStop) / ATR(safe zone ATR length) crosses below safe zone multiplier / 2
Exit: Short, abs(close - TrailStop) / ATR(safe zone ATR length) crosses below safe zone multiplier / 2