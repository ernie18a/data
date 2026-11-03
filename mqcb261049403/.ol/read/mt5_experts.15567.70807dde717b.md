Calculation: Close-based VWAP = sum(close × volume) / sum(volume) over the lookback, calculated on lower-timeframe bars; evaluate the three most recent completed bars as oldest, middle, newest.
Long: middle VWAP < newest VWAP AND oldest VWAP > middle VWAP
Short: middle VWAP > newest VWAP AND oldest VWAP < middle VWAP
Exit: long, middle VWAP > newest VWAP AND oldest VWAP < middle VWAP
Exit: short, middle VWAP < newest VWAP AND oldest VWAP > middle VWAP