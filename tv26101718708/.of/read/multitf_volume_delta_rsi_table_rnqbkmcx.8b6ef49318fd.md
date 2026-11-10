Calculation: Timeframe data = for each enabled selected timeframe, use the latest completed higher-timeframe bar at the chart bar close, the last completed lower-timeframe bar within the chart bar, or the current chart bar when timeframes match; calculate RSI in that timeframe using the same lookback across timeframes.
Calculation: Buy fraction = (close - low) / (high - low) when high > low and volume > 0; otherwise 0.5, using the selected timeframe bar.
Calculation: Bullish timeframe = buy fraction >= dominance threshold AND RSI < upper RSI threshold.
Calculation: Bearish timeframe = buy fraction <= 1 - dominance threshold AND RSI > lower RSI threshold AND bullish timeframe = false.
Long: buy fraction > 0.5
Short: buy fraction < 0.5
Long: RSI <= lower RSI threshold
Short: RSI >= upper RSI threshold
Long: bullish timeframe = true
Short: bearish timeframe = true
Long: count of enabled bullish timeframes >= bullish count threshold
Short: count of enabled bearish timeframes >= bearish count threshold