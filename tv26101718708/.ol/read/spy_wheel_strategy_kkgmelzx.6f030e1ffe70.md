Calculation: 200-period SMA = simple moving average of close over a longer lookback than the 20-period EMA
Calculation: 20-period EMA = exponential moving average of close over a shorter lookback than the 200-period SMA
Calculation: Covered-call strike = round close × (1 + the applicable out-of-the-money percentage) up to the next whole dollar; use the prior completed bar’s strike in normal volatility and the current bar’s strike in high volatility
Calculation: Consecutive SMA breaches = count of consecutive completed bars with close below the 200-period SMA; reset to zero otherwise
Long: Flat AND (strategy start datetime reached OR prior bar’s close exceeded its active covered-call strike and that strike was at least the entry price OR previously exited by the SMA breach rule and close is above the 200-period SMA)
Long: CSP re-entry enabled AND flat AND close above the 200-period SMA AND close above the 20-period EMA AND RSI is outside its blocked range AND VIX below its threshold AND (VWAP gate disabled OR close at or above VWAP) AND macro block off AND low at or below the CSP strike
Short:
Exit: Long, close exceeds the active covered-call strike AND that strike is at least the entry price
Exit: Long, close is below the 200-period SMA for the configured number of consecutive bars