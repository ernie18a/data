Long: VWAP(hlc3) > VWAP(hlc3)[1] AND RSI(close, lookback) > long threshold AND datetime is within the market session
Short: VWAP(hlc3) < VWAP(hlc3)[1] AND RSI(close, lookback) < short threshold AND datetime is within the market session
Exit: long, VWAP(hlc3) < VWAP(hlc3)[1] when VWAP reversal exit is enabled
Exit: short, VWAP(hlc3) > VWAP(hlc3)[1] when VWAP reversal exit is enabled
Exit: long, datetime is outside the market session
Exit: short, datetime is outside the market session