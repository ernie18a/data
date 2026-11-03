Calculation: Fast EMA = EMA of close with a shorter lookback than the slow EMA
Calculation: Slow EMA = EMA of close with a longer lookback than the fast EMA
Calculation: Higher-timeframe EMA = EMA of close on a higher timeframe, using the last completed higher-timeframe bar
Calculation: ATR percentage = ATR divided by close, multiplied by 100
Long: Close crosses above the fast EMA AND fast EMA > slow EMA AND close > higher-timeframe EMA AND RSI > buy threshold AND MACD line > MACD signal line AND MACD histogram > its previous value AND ATR percentage >= minimum volatility threshold AND bar time is within the configured session when the session filter is enabled
Short: Close crosses below the fast EMA AND fast EMA < slow EMA AND close < higher-timeframe EMA AND RSI < sell threshold AND MACD line < MACD signal line AND MACD histogram < its previous value AND ATR percentage >= minimum volatility threshold AND bar time is within the configured session when the session filter is enabled