Calculation: SessionHigh(session) = highest high over the most recent completed session
Calculation: SessionLow(session) = lowest low over the most recent completed session
Calculation: TakesHigh(level) = (close-back confirmation enabled AND high > level AND close < level) OR (close-back confirmation disabled AND high >= level)
Calculation: TakesLow(level) = (close-back confirmation enabled AND low < level AND close > level) OR (close-back confirmation disabled AND low <= level)
Calculation: SweepOfLows = (first bar within London session where TakesLow(SessionLow(Asia session))) OR (first bar within New York session where TakesLow(SessionLow(London session))) OR (Asia sweep in New York enabled AND first bar within New York session where TakesLow(SessionLow(Asia session)))
Calculation: SweepOfHighs = (first bar within London session where TakesHigh(SessionHigh(Asia session))) OR (first bar within New York session where TakesHigh(SessionHigh(London session))) OR (Asia sweep in New York enabled AND first bar within New York session where TakesHigh(SessionHigh(Asia session)))
Calculation: DisplacementCandle = high - low >= ATR(atr length) * displacement multiplier AND (volume filter disabled OR volume >= SMA(volume, volume baseline length) * volume multiplier)
Calculation: BullishCandidate = expansion enabled AND BarsSince(SweepOfLows) <= expansion window AND DisplacementCandle AND close > open AND close > Highest(high, breakout lookback)[1]
Calculation: BearishCandidate = expansion enabled AND BarsSince(SweepOfHighs) <= expansion window AND DisplacementCandle AND close < open AND close < Lowest(low, breakout lookback)[1]
Long: SweepOfLows
Short: SweepOfHighs
Long: BullishCandidate AND no BullishCandidate on an earlier bar from the most recent SweepOfLows onward
Short: BearishCandidate AND no BearishCandidate on an earlier bar from the most recent SweepOfHighs onward