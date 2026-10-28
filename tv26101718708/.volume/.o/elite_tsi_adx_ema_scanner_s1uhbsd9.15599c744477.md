Calculation: TSI = True Strength Index using a shorter momentum smoothing lookback followed by a longer one.
Calculation: ADX = Average Directional Index using the same lookback for directional movement and ADX smoothing.
Calculation: Fast, slow, and trend EMA = EMAs with progressively longer lookbacks.
Calculation: Higher-timeframe close and trend EMA = close and EMA, using the trend EMA lookback, from the last completed higher-timeframe bar.
Long: TSI > 0 AND ADX > minimum threshold AND fast EMA > slow EMA AND close > trend EMA AND higher-timeframe close > higher-timeframe trend EMA AND volume > its simple moving average AND the same combined condition was false on the previous chart bar.
Short: TSI < 0 AND ADX > minimum threshold AND fast EMA < slow EMA AND close < trend EMA AND higher-timeframe close < higher-timeframe trend EMA AND volume > its simple moving average AND the same combined condition was false on the previous chart bar.