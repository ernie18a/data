Calculation: last swing high = most recent PivotHigh(high, swing lookback, swing lookback) value
Calculation: last swing low = most recent PivotLow(low, swing lookback, swing lookback) value
Calculation: bullish sweep = low < last swing low AND close > last swing low
Calculation: bearish sweep = high > last swing high AND close < last swing high
Calculation: swept low = last swing low on the most recent bar where bullish sweep is true
Calculation: swept high = last swing high on the most recent bar where bearish sweep is true
Calculation: long manipulation invalidated = manipulation filter enabled AND close < swept low on any bar since the most recent bar where bullish sweep is true
Calculation: short manipulation invalidated = manipulation filter enabled AND close > swept high on any bar since the most recent bar where bearish sweep is true
Calculation: DOL above = lowest value above close among the most recent DOL count PivotHigh values
Calculation: DOL below = highest value below close among the most recent DOL count PivotLow values
Calculation: delivery candle = high - low > 0 AND abs(close - open) >= delivery body ratio * (high - low)
Calculation: bullish CISD = close > the open of the most recent delivery candle with close < open, and no earlier bar after that candle has closed above that open
Calculation: bearish CISD = close < the open of the most recent delivery candle with close > open, and no earlier bar after that candle has closed below that open
Calculation: touch(zone) = zone exists AND low <= zone top AND high >= zone bottom
Calculation: bull HTF zone(T) = for T1 < T2 < T3 < T4 < T5, the zone of the latest bull FVG of T, where on each chart bar that opens a new T bar a bull FVG forms if T high[2] < T low[0] on the last completed T bar, with top = T low[0] and bottom = T high[2]; the zone is removed on any chart bar, including its formation bar, whose close is above top
Calculation: bear HTF zone(T) = for T1 < T2 < T3 < T4 < T5, the zone of the latest bear FVG of T, where on each chart bar that opens a new T bar a bear FVG forms if T low[2] > T high[0] on the last completed T bar, with top = T low[2] and bottom = T high[0]; the zone is removed on any chart bar, including its formation bar, whose close is below bottom
Calculation: wick threshold = ATR(high, low, close, ATR lookback) * data wick multiple
Long: (touch(bull HTF zone(T1)) OR touch(bull HTF zone(T2)) OR touch(bull HTF zone(T3)) OR touch(bull HTF zone(T4)) OR touch(bull HTF zone(T5))) AND (bullish CISD OR NOT CISD required) AND ((low < LOWEST(low, SMT lookback)[1] AND correlated instrument low > LOWEST(correlated instrument low, SMT lookback)[1]) OR NOT SMT required) AND NOT (DOL filter enabled AND DOL above exists AND DOL below exists AND (close - DOL below) < (DOL above - close)) AND NOT (data wick filter enabled AND min(open, close) - low > wick threshold) AND NOT long manipulation invalidated
Short: (touch(bear HTF zone(T1)) OR touch(bear HTF zone(T2)) OR touch(bear HTF zone(T3)) OR touch(bear HTF zone(T4)) OR touch(bear HTF zone(T5))) AND (bearish CISD OR NOT CISD required) AND ((high > HIGHEST(high, SMT lookback)[1] AND correlated instrument high < HIGHEST(correlated instrument high, SMT lookback)[1]) OR NOT SMT required) AND NOT (DOL filter enabled AND DOL above exists AND DOL below exists AND (DOL above - close) < (close - DOL below)) AND NOT (data wick filter enabled AND high - max(open, close) > wick threshold) AND NOT short manipulation invalidated