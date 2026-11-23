Calculation: Weekday = dayofweek(datetime)
Calculation: MovAvg = MA(close, MA length, MA type)
Calculation: ATR = ATR(ATR length)
Calculation: AvgATR = SMA(ATR, averaging length)
Calculation: HighA = Highest(high, lookback A)
Calculation: LowA = Lowest(low, lookback A)
Calculation: HighE = Highest(high, lookback E)
Calculation: LowE = Lowest(low, lookback E)
Calculation: Midpoint = (Highest(high, lookback D) + Lowest(low, lookback D)) / 2
Calculation: FallCount(window) = count of offsets i from 0 to window - 1 where close[i] < close[i+1]
Calculation: BullFridayHigh = Weekday == Friday AND high == HighA
Calculation: BullTuesdayLow = Weekday == Tuesday AND low == LowA AND close > open
Calculation: BullHighBreakout = high == Highest(high, lookback B) AND high > high[1]
Calculation: BullMACross = close crosses above MovAvg
Calculation: BullRiseDip = close > close[short rise offset] AND high > high[short rise offset] AND FallCount(short fall window) >= short fall count AND close > MovAvg
Calculation: BullBigCandle = close - open >= ATR * body multiplier
Calculation: BullThreeBarHigh = high == Highest(high, lookback C) AND close > MovAvg AND high > high[1]
Calculation: BullSwingLows = low < low[short swing offset] AND low < low[long swing offset] AND close > open
Calculation: BullSurge = ATR > AvgATR * surge multiplier AND Abs(close - open) >= ATR * candle multiplier AND close > MovAvg
Calculation: BullMidpoint = Abs(close - Midpoint) <= ATR * band multiplier AND close > MovAvg
Calculation: BullQuarterBreak = high == HighE AND (high > high[1] OR (low == LowE AND low < low[1]))
Calculation: BearFridayLow = Weekday == Friday AND low == LowA
Calculation: BearWednesdayHigh = Weekday == Wednesday AND high == HighA AND close < open
Calculation: BearLowBreakout = low == Lowest(low, lookback B) AND low < low[1]
Calculation: BearRiseDip = close > close[long rise offset] AND high > high[long rise offset] AND FallCount(long fall window) >= long fall count AND close < MovAvg
Calculation: BearGrowingCorrection = Abs(high[short range offset] - low) > Abs(high[long range offset] - low[short range offset]) AND Abs(high[short range offset] - low) > ATR * range multiplier
Calculation: BearMidpoint = Abs(close - Midpoint) <= ATR * band multiplier AND close < MovAvg
Calculation: BearSwingHighs = high > high[short swing offset] AND high > high[long swing offset] AND close < open
Calculation: BearSurge = ATR > AvgATR * surge multiplier AND Abs(close - open) >= ATR * candle multiplier AND close < MovAvg
Calculation: BearQuarterBreak = low == LowE AND (low < low[1] OR (high == HighE AND high > high[1]))
Calculation: BullCount = number of true among BullFridayHigh, BullTuesdayLow, BullHighBreakout, BullMACross, BullRiseDip, BullBigCandle, BullThreeBarHigh, BullSwingLows, BullSurge, BullMidpoint, BullQuarterBreak
Calculation: BearCount = number of true among BearFridayLow, BearWednesdayHigh, BearLowBreakout, BearRiseDip, BearGrowingCorrection, BearMidpoint, BearSwingHighs, BearSurge, BearQuarterBreak
Calculation: LongConsensus = BullCount >= minimum rules AND BullCount > BearCount
Calculation: ShortConsensus = BearCount >= minimum rules AND BearCount > BullCount
Long: LongConsensus
Long: LongConsensus AND NOT LongConsensus[1]
Short: ShortConsensus
Short: ShortConsensus AND NOT ShortConsensus[1]
Long: BullFridayHigh
Long: BullFridayHigh AND NOT BullFridayHigh[1]
Long: BullTuesdayLow
Long: BullHighBreakout
Long: BullHighBreakout AND NOT BullHighBreakout[1]
Long: BullMACross
Long: BullRiseDip
Long: BullBigCandle
Long: BullThreeBarHigh
Long: BullSwingLows
Long: BullSurge
Long: BullMidpoint
Long: BullQuarterBreak
Short: BearFridayLow
Short: BearFridayLow AND NOT BearFridayLow[1]
Short: BearWednesdayHigh
Short: BearLowBreakout
Short: BearRiseDip
Short: BearGrowingCorrection
Short: BearMidpoint
Short: BearSwingHighs
Short: BearSurge
Short: BearQuarterBreak