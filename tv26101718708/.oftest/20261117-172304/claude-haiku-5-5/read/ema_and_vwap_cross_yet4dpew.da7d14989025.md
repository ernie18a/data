Calculation: EMA = exponential moving average of close with the EMA length parameter
Calculation: VWAP = cumulative sum of (close * volume) divided by cumulative sum of volume, restarted at the beginning of each trading day
Long: EMA > VWAP
Short: EMA < VWAP
Exit: long, EMA < VWAP
Exit: short, EMA > VWAP