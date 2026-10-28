Long: VWAP > previous bar VWAP AND RSI(close, lookback) > buy threshold AND bar hour > trade start hour AND bar hour < close hour
Short: VWAP < previous bar VWAP AND RSI(close, lookback) < sell threshold AND bar hour > trade start hour AND bar hour < close hour
Exit: long, VWAP < previous bar VWAP OR bar hour = close hour
Exit: short, VWAP > previous bar VWAP OR bar hour = close hour