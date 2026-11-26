Calculation: structure bias = neutral initially; on each confirmed bar, set bullish when close crosses above the latest confirmed Pivot High(high, structure lookback, structure lookback) while prior bias is neutral or bearish, set bearish when close crosses below the latest confirmed Pivot Low(low, structure lookback, structure lookback) while then-current bias is neutral or bullish, and otherwise retain its value
Long: confirmed bar, close crosses above the latest confirmed Pivot High(high, structure lookback, structure lookback), and prior structure bias is neutral or bearish
Short: confirmed bar, close crosses below the latest confirmed Pivot Low(low, structure lookback, structure lookback), and prior structure bias is neutral or bullish
Long: structure bias is bullish
Short: structure bias is bearish
Calculation: bullish OB zone = full high-low range of the nearest prior bearish candle within OB scan multiplier × structure lookback bars when bullish structure flip occurs; retain at most maximum active OB count per side, evicting the oldest zone, and mark each zone mitigated on its first confirmed bar with low within its range
Calculation: bearish OB zone = full high-low range of the prior bullish candle with the greatest high within OB scan multiplier × structure lookback bars when bearish structure flip occurs; ties select the nearest prior candle; retain at most maximum active OB count per side, evicting the oldest zone, and mark each zone mitigated on its first confirmed bar with high within its range
Long: bullish structure flip occurs and a prior bearish candle exists within OB scan multiplier × structure lookback bars
Short: bearish structure flip occurs and a prior bullish candle exists within OB scan multiplier × structure lookback bars
Long: confirmed bar, an active unmitigated bullish OB zone exists, and low is within its range
Short: confirmed bar, an active unmitigated bearish OB zone exists, and high is within its range
Long: confirmed bar, low > high[2], and low - high[2] >= minimum FVG size ATR multiple × ATR(ATR lookback)
Short: confirmed bar, high < low[2], and low[2] - high >= minimum FVG size ATR multiple × ATR(ATR lookback)