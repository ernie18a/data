Calculation: short EMA = exponential moving average of close with a shorter lookback than long EMA
Calculation: long EMA = exponential moving average of close with a longer lookback than short EMA
Calculation: VWAP = cumulative sum of (close × volume) divided by cumulative sum of volume, from the start of the session
Long: close > VWAP AND short EMA > long EMA AND previous short EMA <= previous long EMA
Short: close < VWAP AND short EMA < long EMA AND previous short EMA >= previous long EMA