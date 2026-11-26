Calculation: Average volume = SMA(volume, volume lookback)
Calculation: Average range = SMA(high - low, average range lookback)
Calculation: Range midpoint = (highest(high, volume lookback) + lowest(low, volume lookback)) / 2
Calculation: Climax volume condition = volume > Average volume * (volume spike multiplier + climax volume add-on)
Calculation: Selling climax condition = Climax volume condition AND close < open AND low <= lowest(low, selling climax lookback) AND close < close[1]
Calculation: Most recent selling climax low = valuewhen(Selling climax condition, low, most recent)
Calculation: Spring condition = low < lowest(low[1], spring lookback) AND close > open AND volume > Average volume AND close > low * spring rebound multiplier
Calculation: Secondary accumulation test condition = low < Most recent selling climax low * upper accumulation test multiplier AND low > Most recent selling climax low * lower accumulation test multiplier AND volume < Average volume AND close > open
Calculation: Last support condition = low > valuewhen(Spring condition OR Secondary accumulation test condition, low, most recent) AND close > open AND volume < Average volume AND close > Range midpoint
Calculation: Buying climax condition = Climax volume condition AND close > open AND high >= highest(high, buying climax lookback)
Calculation: Most recent buying climax high = valuewhen(Buying climax condition, high, most recent)
Calculation: Upthrust after distribution condition = high > highest(high[1], upthrust lookback) AND close < open AND volume > Average volume AND close < high * upthrust rejection multiplier
Calculation: Secondary distribution test condition = high > Most recent buying climax high * lower distribution test multiplier AND high < Most recent buying climax high * upper distribution test multiplier AND volume < Average volume
Calculation: Last supply condition = high < valuewhen(Upthrust after distribution condition OR Secondary distribution test condition, high, most recent) AND close < open AND volume < Average volume AND close < Range midpoint
Long: Selling climax condition
Long: close > open AND volume > Average volume AND low[1] = lowest(low[1], automatic rally lookback) AND close > close[1] * rally price multiplier
Long: Spring condition
Long: close > close[1] AND volume > Average volume * strength volume multiplier AND close - open > Average range AND close > Range midpoint
Long: Last support condition
Short: Buying climax condition
Short: Upthrust after distribution condition
Short: Last supply condition