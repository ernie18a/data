Calculation: fast EMA = exponential moving average of close over fast length, where fast length is less than slow length
Calculation: slow EMA = exponential moving average of close over slow length
Calculation: VWAP = cumulative sum of (close × volume) divided by cumulative sum of volume, reset at the start of each session
Long: close > VWAP AND fast EMA > slow EMA AND previous-bar fast EMA <= previous-bar slow EMA
Short: close < VWAP AND fast EMA < slow EMA AND previous-bar fast EMA >= previous-bar slow EMA