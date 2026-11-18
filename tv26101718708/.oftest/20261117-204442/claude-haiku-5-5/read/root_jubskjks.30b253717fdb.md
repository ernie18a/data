Calculation: sma = simple moving average of close over sma_length bars
Calculation: vwap = cumulative sum of (hlc3 × volume) divided by cumulative sum of volume, accumulated from the start of each session, where hlc3 = (high + low + close) / 3
Long: sma > vwap AND sma at previous bar <= vwap at previous bar
Short: sma < vwap AND sma at previous bar >= vwap at previous bar