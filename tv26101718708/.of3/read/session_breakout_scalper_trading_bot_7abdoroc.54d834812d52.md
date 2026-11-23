Calculation: BoxFormed_i = datetime[lookback i] equals session start i AND session i enabled
Calculation: BoxHigh = highest(high, 2 * lookback i) on a bar where BoxFormed_i holds for some i, otherwise previous BoxHigh
Calculation: BoxLow = lowest(low, 2 * lookback i) on a bar where BoxFormed_i holds for some i, otherwise previous BoxLow
Calculation: LargeTradeIndex(lookback, type) = (MA(close - close[lookback], lookback, type) / ATR(lookback)) * 50 + 50
Calculation: StopDistance = if ATR stop enabled then ATR(stop lookback) * ATR factor sampled on the latest bar where BoxFormed_i holds for some i, otherwise fixed stop distance of the position side
Long: high crosses above BoxHigh AND no entry has occurred since BoxHigh was last updated
Short: low crosses below BoxLow AND no entry has occurred since BoxLow was last updated
Exit: long, (index regime filter enabled AND LargeTradeIndex(lookback, type)[1] <= sentiment level) OR (Andean regime filter enabled AND Andean Oscillator bull line(alpha length)[1] <= Andean Oscillator bear line(alpha length)[1])
Exit: short, (index regime filter enabled AND LargeTradeIndex(lookback, type)[1] >= -sentiment level) OR (Andean regime filter enabled AND Andean Oscillator bear line(alpha length)[1] <= Andean Oscillator bull line(alpha length)[1])
Exit: long, low crosses below entry price - StopDistance OR high crosses above entry price + long take-profit distance
Exit: short, high crosses above entry price + StopDistance OR low crosses below entry price - short take-profit distance
Exit: long, datetime equals session start i for some enabled session i
Exit: short, datetime equals session start i for some enabled session i