Long: close > VWAP AND abs(close - VWAP) / VWAP < pullback tolerance / 100 AND RSI(close, RSI lookback) > oversold threshold
Short: close < VWAP AND abs(close - VWAP) / VWAP < pullback tolerance / 100 AND RSI(close, RSI lookback) < overbought threshold
Exit: long, low <= VWAP × long stop multiplier OR high >= VWAP × long profit multiplier
Exit: short, high >= VWAP × short stop multiplier OR low <= VWAP × short profit multiplier