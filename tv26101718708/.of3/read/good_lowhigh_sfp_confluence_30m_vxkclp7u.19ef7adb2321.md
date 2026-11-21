Calculation: ATR = ATR(ATR length)
Calculation: MovAvg = MA(close, MA length, MA type)
Calculation: POC = midpoint of the bucket with the largest volume, where the range from Lowest(low, POC lookback) to Highest(high, POC lookback) is split into POC buckets of equal width (lowest bucket wins ties), and a bucket's volume is the sum of volume over the last POC lookback bars including the current bar whose high >= bucket low and low <= bucket high; POC lookback is longer than Fib lookback
Calculation: FibHigh = Highest(high, Fib lookback), where Fib lookback is longer than SFP lookback
Calculation: FibLow = Lowest(low, Fib lookback)
Calculation: PriorLow = Lowest(low[1], SFP lookback)
Calculation: PriorHigh = Highest(high[1], SFP lookback)
Calculation: LastPivotLow = value of the most recent non-na PivotLow(low, swing lookback, swing lookback)
Calculation: LowHoldCount = 1 + number of bars after the bar on which LastPivotLow was last set, through the current bar, where low <= LastPivotLow + ATR * ATR tolerance multiplier
Calculation: LastPivotHigh = value of the most recent non-na PivotHigh(high, swing lookback, swing lookback)
Calculation: HighHoldCount = 1 + number of bars after the bar on which LastPivotHigh was last set, through the current bar, where high >= LastPivotHigh - ATR * ATR tolerance multiplier
Calculation: BullConfluence = CountTrue(abs(close - MovAvg) <= ATR * confluence proximity multiplier, abs(close - POC) <= ATR * confluence proximity multiplier, abs(close - Fibonacci retracement(FibHigh, FibLow, Fib ratio, measured up from FibLow)) <= ATR * confluence proximity multiplier)
Calculation: BearConfluence = CountTrue(abs(close - MovAvg) <= ATR * confluence proximity multiplier, abs(close - POC) <= ATR * confluence proximity multiplier, abs(close - Fibonacci retracement(FibHigh, FibLow, Fib ratio, measured down from FibHigh)) <= ATR * confluence proximity multiplier)
Long: low < PriorLow AND close > PriorLow AND PriorLow - low >= ATR * SFP min wick multiplier
Long: low < PriorLow AND close > PriorLow AND PriorLow - low >= ATR * SFP min wick multiplier AND BullConfluence >= min confluence levels
Short: high > PriorHigh AND close < PriorHigh AND high - PriorHigh >= ATR * SFP min wick multiplier
Short: high > PriorHigh AND close < PriorHigh AND high - PriorHigh >= ATR * SFP min wick multiplier AND BearConfluence >= min confluence levels
Long: low <= LastPivotLow + ATR * ATR tolerance multiplier AND LowHoldCount >= confirm bars AND NOT (a previous bar from the bar on which LastPivotLow was last set onward satisfies low <= LastPivotLow + ATR * ATR tolerance multiplier AND LowHoldCount >= confirm bars)
Short: high >= LastPivotHigh - ATR * ATR tolerance multiplier AND HighHoldCount >= confirm bars AND NOT (a previous bar from the bar on which LastPivotHigh was last set onward satisfies high >= LastPivotHigh - ATR * ATR tolerance multiplier AND HighHoldCount >= confirm bars)