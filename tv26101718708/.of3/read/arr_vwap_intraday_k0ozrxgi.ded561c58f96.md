Long: VWAP > VWAP[1] AND RSI(close, lookback) > long RSI threshold AND hour(datetime) > start-hour parameter AND hour(datetime) < end-hour parameter
Short: VWAP < VWAP[1] AND RSI(close, lookback) < short RSI threshold AND hour(datetime) > start-hour parameter AND hour(datetime) < end-hour parameter
Exit: long, (reversal-exit setting enabled AND VWAP < VWAP[1]) OR hour(datetime) = end-hour parameter
Exit: short, (reversal-exit setting enabled AND VWAP > VWAP[1]) OR hour(datetime) = end-hour parameter