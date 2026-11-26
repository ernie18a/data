Calculation: trend EMA = EMA(close from the chart timeframe or configured T1 timeframe’s still-forming bar, trend lookback), calculated on chart bars
Calculation: MACD histogram = MACD histogram of close from the chart timeframe or configured T1 timeframe’s still-forming bar, calculated on chart bars, with separate fast EMA and slow EMA lookbacks (fast shorter than slow) and an SMA signal lookback
Long: trend EMA > trend EMA[1] AND MACD histogram > MACD histogram[1]
Short: trend EMA < trend EMA[1] AND MACD histogram < MACD histogram[1]
Exit: long, NOT (trend EMA > trend EMA[1] AND MACD histogram > MACD histogram[1]) AND NOT (trend EMA < trend EMA[1] AND MACD histogram < MACD histogram[1])
Exit: short, NOT (trend EMA > trend EMA[1] AND MACD histogram > MACD histogram[1]) AND NOT (trend EMA < trend EMA[1] AND MACD histogram < MACD histogram[1])