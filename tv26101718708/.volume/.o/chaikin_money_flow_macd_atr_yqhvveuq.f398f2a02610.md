Calculation: Higher-timeframe EMA = EMA of close on the selected higher timeframe, using the latest available bar (the forming bar in real time)
Calculation: Long target = entry price + ATR at entry × long profit multiple
Calculation: Long stop = entry price − ATR at entry × long stop multiple
Calculation: Short target = entry price − ATR at entry × short profit multiple
Calculation: Short stop = entry price + ATR at entry × short stop multiple
Long: datetime is within the configured trading window AND position is flat AND at least one of MACD crosses above its signal line, MACD > 0, Chaikin Money Flow > 0, or close > higher-timeframe EMA
Short: datetime is within the configured trading window AND position is flat AND at least one of MACD crosses below its signal line, MACD < 0, Chaikin Money Flow < 0, or close < higher-timeframe EMA
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target