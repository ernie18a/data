Calculation: Main moving average = MA(close, shorter lookback, main MA type)
Calculation: Trend moving average = MA(close, longer lookback, trend MA type)
Calculation: Long confirmation pending = set by a close crossing above the main moving average in full-candle confirmation mode when the trend filter is disabled or the main moving average is above the trend moving average; cleared by a close crossing below the main moving average, a bar when the enabled trend filter fails, or a long confirmation entry
Calculation: Short confirmation pending = set by a close crossing below the main moving average in full-candle confirmation mode when the trend filter is disabled or the main moving average is below the trend moving average; cleared by a close crossing above the main moving average, a bar when the enabled trend filter fails, or a short confirmation entry
Long: close > main moving average
Short: close <= main moving average
Long: crossover entry mode AND long trades enabled AND close crosses above the main moving average AND (trend filter disabled OR main moving average > trend moving average)
Long: full-candle confirmation mode AND long trades enabled AND long confirmation pending AND open > main moving average AND high > main moving average AND low > main moving average AND close > main moving average AND (trend filter disabled OR main moving average > trend moving average)
Short: crossover entry mode AND short trades enabled AND close crosses below the main moving average AND (trend filter disabled OR main moving average < trend moving average)
Short: full-candle confirmation mode AND short trades enabled AND short confirmation pending AND open < main moving average AND high < main moving average AND low < main moving average AND close < main moving average AND (trend filter disabled OR main moving average < trend moving average)
Exit: long, close crosses below the main moving average
Exit: short, close crosses above the main moving average