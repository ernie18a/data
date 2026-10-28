Calculation: Candle body high = max(open, close)
Calculation: Long trailing stop = while long, max(candle body high × (1 − configured trailing distance), previous trailing stop); otherwise reset to zero
Long: datetime is on or after the configured start date AND the shorter-lookback SMA crosses above the longer-lookback SMA
Long: datetime is on or after the configured start date AND the shorter-lookback SMA crosses above the longer-lookback SMA AND RSI > its configured lower threshold AND (the shorter-lookback SMA is at least the longer-lookback SMA OR the medium-lookback SMA is at least the longer-lookback SMA)
Exit: long, the shorter-lookback SMA crosses below the longer-lookback SMA
Exit: long, close < entry price × (1 − configured stop-loss threshold)
Exit: long, the shorter-lookback SMA crosses below the longer-lookback SMA AND close < the medium-lookback SMA AND volume >= its moving average
Exit: long, candle body high >= entry price × (1 + configured trailing-stop activation threshold) AND close <= long trailing stop