Calculation: Inside bar = high <= prior high AND low >= prior low
Calculation: Type 1 candle = low < prior low AND high > prior high AND close >= prior low AND close <= prior high
Calculation: Bullish C2 = low < prior low AND close > prior low
Calculation: Bearish C2 = high > prior high AND close < prior high
Calculation: Failed bullish C2 = low < prior low AND close <= prior low
Calculation: Failed bearish C2 = high > prior high AND close >= prior high
Calculation: Bullish C3 = prior bar is a failed bullish C2 AND current low >= prior low AND current close > the low two bars ago
Calculation: Bearish C3 = prior bar is a failed bearish C2 AND current high <= prior high AND current close < the high two bars ago
Calculation: Candle bias = 0 if Type 1 or inside bar; otherwise +1 for bullish C2, -1 for bearish C2, +1 for bullish C3, -1 for bearish C3, +1 if close > prior close, -1 if close < prior close, otherwise 0, applying this order
Calculation: Higher-timeframe bias = candle bias of the last completed bar on each higher timeframe
Calculation: Chart-timeframe prior-bar bias = candle bias of the immediately prior completed chart-timeframe bar
Long: Bullish C2 OR bullish C3
Long: (Bullish C2 OR bullish C3) AND both higher-timeframe biases = +1 AND chart-timeframe prior-bar bias = +1 AND bar close is between 06:00 and 11:30 ET, inclusive
Short: Bearish C2 OR bearish C3
Short: (Bearish C2 OR bearish C3) AND both higher-timeframe biases = -1 AND chart-timeframe prior-bar bias = -1 AND bar close is between 06:00 and 11:30 ET, inclusive