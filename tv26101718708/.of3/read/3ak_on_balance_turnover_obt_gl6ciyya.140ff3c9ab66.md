Calculation: on-balance turnover = CUM(sign(change(close)) * volume * close)
Long: on-balance turnover = highest(on-balance turnover, lookback) AND high != highest(high, lookback)
Long: on-balance turnover = highest(on-balance turnover, lookback) AND high = highest(high, lookback)
Long: on-balance turnover >= on-balance turnover[1]
Short: on-balance turnover < on-balance turnover[1]