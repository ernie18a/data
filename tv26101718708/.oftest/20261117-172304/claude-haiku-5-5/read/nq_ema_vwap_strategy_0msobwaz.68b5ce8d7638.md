Calculation: fast EMA = exponential moving average of close with a shorter lookback than slow EMA
Calculation: slow EMA = exponential moving average of close with a longer lookback than fast EMA
Calculation: VWAP = cumulative sum of (close x volume) divided by cumulative sum of volume, from the start of the session
Long: fast EMA > slow EMA AND fast EMA[1] <= slow EMA[1] AND close > VWAP
Short: fast EMA < slow EMA AND fast EMA[1] >= slow EMA[1] AND close < VWAP