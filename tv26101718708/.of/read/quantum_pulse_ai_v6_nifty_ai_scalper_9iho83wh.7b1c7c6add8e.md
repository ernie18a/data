Calculation: Relative volume = current volume divided by its moving average
Calculation: AI feature vector = ATR-scaled, clamped values for fast-minus-slow moving average, close-minus-daily VWAP, the change in HMA over a short lookback, and relative volume
Calculation: Historical direction label = bullish when the close at a more recent lag is greater than the close at an older lag; bearish when lower; otherwise neutral
Calculation: Bull confidence = percentage of the nearest historical feature vectors labeled bullish
Calculation: Bear confidence = percentage of the nearest historical feature vectors labeled bearish
Long: AI enabled AND bull confidence >= confidence threshold AND close > daily VWAP AND ADX > trend threshold AND the same AI long condition was false on the previous bar AND last signaled direction is not long
Short: AI enabled AND bear confidence >= confidence threshold AND close < daily VWAP AND ADX > trend threshold AND the same AI short condition was false on the previous bar AND last signaled direction is not short
Long: AI disabled AND fast moving average > slow moving average AND close > daily VWAP AND fast moving average > daily VWAP AND HMA > its value at a shorter lag AND close > HMA AND Supertrend is bullish AND ADX > trend threshold AND relative volume > volume threshold AND the same long condition was false on the previous bar AND last signaled direction is not long
Short: AI disabled AND fast moving average < slow moving average AND close < daily VWAP AND fast moving average < daily VWAP AND HMA < its value at a shorter lag AND close < HMA AND Supertrend is bearish AND ADX > trend threshold AND relative volume > volume threshold AND the same short condition was false on the previous bar AND last signaled direction is not short
Long: Fast moving average crosses above slow moving average
Short: Fast moving average crosses below slow moving average
Long: Fast moving average crosses above daily VWAP
Short: Fast moving average crosses below daily VWAP