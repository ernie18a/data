Long: close > VWAP AND abs(close - VWAP) / VWAP < pullback tolerance AND RSI > oversold threshold
Short: close < VWAP AND abs(close - VWAP) / VWAP < pullback tolerance AND RSI < overbought threshold
Exit: long, low <= VWAP * 0.995 OR high >= VWAP * 1.02
Exit: short, high >= VWAP * 1.005 OR low <= VWAP * 0.98