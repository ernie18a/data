Calculation: Buy volume = sum of lower-timeframe bar volume where close > open, plus half the volume where close = open; if no lower-timeframe bars are available, use the current bar’s volume when close > open, half when close = open, otherwise 0.
Calculation: Sell volume = sum of lower-timeframe bar volume where close < open, plus half the volume where close = open; if no lower-timeframe bars are available, use the current bar’s volume when close < open, half when close = open, otherwise 0.
Long: Buy volume >= sell volume
Short: Sell volume > buy volume