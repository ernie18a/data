Calculation: Upper boundary = highest higher-timeframe open from the previous chart bar over a lookback parameter
Calculation: Lower boundary = lowest higher-timeframe open from the previous chart bar over a separate lookback parameter
Long: close > upper boundary AND upper boundary two chart bars ago > upper boundary one chart bar ago
Short: close < lower boundary AND lower boundary two chart bars ago > lower boundary one chart bar ago
Exit: long, price reaches the entry price plus a profit-target parameter OR price reaches the entry price minus a loss-limit parameter OR the trailing stop is reached
Exit: short, price reaches the entry price minus a profit-target parameter OR price reaches the entry price plus a loss-limit parameter OR the trailing stop is reached