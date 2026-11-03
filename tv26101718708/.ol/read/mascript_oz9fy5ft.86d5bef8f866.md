Calculation: Trailing stop = highest value of (bar body high × (1 − configured trail percentage)) since entry
Long: datetime is on or after the configured start date AND the shorter-lookback SMA crosses above the longer-lookback SMA AND RSI > 30 AND (the shorter-lookback SMA is >= the longer-lookback SMA OR the shorter-lookback SMA is >= the longer-lookback SMA)
Short: The shorter-lookback SMA crosses below the longer-lookback SMA
Exit: Long, close < 0.94 × entry price
Exit: Long, the shorter-lookback SMA crosses below the longer-lookback SMA AND close < the shorter-lookback SMA AND volume >= its longer-lookback SMA
Exit: Long, bar body high >= 1.2 × entry price AND close <= trailing stop