Calculation: N-bar up-run = close > open on each of the N most recent bars
Calculation: N-bar down-run = close < open on each of the N most recent bars
Calculation: Average volume = simple moving average of volume over a configurable lookback
Calculation: Zone height = average true range over a configurable lookback multiplied by a configurable factor
Calculation: Demand zone = from high of the most recent down candle found within the configurable base lookback through that high minus zone height
Calculation: Supply zone = from low of the most recent up candle found within the configurable base lookback through that low plus zone height
Long: confirmed bar AND N-bar up-run AND volume[1] > average volume[1] AND demand-zone cooldown = 0 AND a down candle exists within the base lookback AND the resulting demand zone does not overlap an active demand zone
Short: confirmed bar AND N-bar down-run AND volume[1] > average volume[1] AND supply-zone cooldown = 0 AND an up candle exists within the base lookback AND the resulting supply zone does not overlap an active supply zone