Calculation: Camarilla H4 = prior completed higher-timeframe bar’s close + (high − low) × 1.1 / 2
Calculation: Camarilla L4 = prior completed higher-timeframe bar’s close − (high − low) × 1.1 / 2
Calculation: EMA = exponential moving average of chart-timeframe closes
Long: close > prior completed higher-timeframe Camarilla H4 AND open < prior completed higher-timeframe Camarilla H4 AND close > EMA
Short: close < prior completed higher-timeframe Camarilla L4 AND open > prior completed higher-timeframe Camarilla L4 AND close < EMA
Exit: long position, low <= entry price − stop-loss distance OR (favorable move from entry has reached trailing-stop activation distance AND low <= highest high since activation − trailing offset)
Exit: short position, high >= entry price + stop-loss distance OR (favorable move from entry has reached trailing-stop activation distance AND high >= lowest low since activation + trailing offset)