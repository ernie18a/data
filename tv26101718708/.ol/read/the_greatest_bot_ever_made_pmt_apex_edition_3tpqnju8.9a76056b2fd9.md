Calculation: Bullish fair value gap = current low > high two bars earlier AND previous close > previous open
Calculation: Bearish fair value gap = current high < low two bars earlier AND previous close < previous open
Long: position side = flat AND (bullish fair value gap OR MACD line crosses above signal line AND RSI < 40) AND volume > 20-bar SMA of volume AND ADX > 20
Short: position side = flat AND (bearish fair value gap OR MACD line crosses below signal line AND RSI > 60) AND volume > 20-bar SMA of volume AND ADX > 20
Exit: long, low <= entry price - stop-loss distance OR trailing stop is active AND low <= highest high since activation - trailing offset
Exit: short, high >= entry price + stop-loss distance OR trailing stop is active AND high >= lowest low since activation + trailing offset