Calculation: EMA = exponential moving average of close on the configured indicator timeframe.
Calculation: MACD histogram = fast EMA of close minus slow EMA of close, minus the signal EMA of that difference, on the configured indicator timeframe.
Calculation: Bullish impulse = EMA > preceding EMA AND MACD histogram > preceding MACD histogram AND MACD histogram > 0.
Calculation: Bearish impulse = EMA < preceding EMA AND MACD histogram < preceding MACD histogram AND MACD histogram < 0.
Calculation: Neutral impulse = (EMA <= preceding EMA AND MACD histogram > 0) OR (EMA <= preceding EMA AND MACD histogram > preceding MACD histogram) OR (EMA >= preceding EMA AND MACD histogram < 0) OR (EMA >= preceding EMA AND MACD histogram < preceding MACD histogram).
Long: Bullish impulse on the last completed indicator-timeframe bar AND (Bearish impulse OR Neutral impulse on the preceding completed indicator-timeframe bar).
Short: Bearish impulse on the last completed indicator-timeframe bar AND (Bullish impulse OR Neutral impulse on the preceding completed indicator-timeframe bar).
Exit: long, Bearish impulse on the last completed indicator-timeframe bar.
Exit: short, Bullish impulse on the last completed indicator-timeframe bar.