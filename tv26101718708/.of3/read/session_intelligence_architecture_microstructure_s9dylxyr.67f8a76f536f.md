Calculation: Market structure bias = neutral initially; set bullish when close crosses above the latest confirmed PivotHigh(high, pivot strength, pivot strength), and set bearish when close crosses below the latest confirmed PivotLow(low, pivot strength, pivot strength).
Long: (in Europe session OR in US session) AND not in Asia session AND close > Asia session high AND high - low > 0 AND abs(close - open) / (high - low) >= minimum breakout body ratio
Short: (in Europe session OR in US session) AND not in Asia session AND close < Asia session low AND high - low > 0 AND abs(close - open) / (high - low) >= minimum breakout body ratio
Long: close crosses above the latest confirmed PivotHigh(high, pivot strength, pivot strength) AND prior market structure bias is bearish
Short: close crosses below the latest confirmed PivotLow(low, pivot strength, pivot strength) AND prior market structure bias is bullish
Long: session close - session open > ATR(lookback) * expansion multiplier AND session volume / historical average volume of same-type sessions > institutional RVOL threshold
Short: session close - session open < -ATR(lookback) * expansion multiplier AND session volume / historical average volume of same-type sessions > institutional RVOL threshold
Long: session open and session VWAP are defined AND session close > session VWAP(hlc3, volume)
Short: session open and session VWAP are defined AND session close <= session VWAP(hlc3, volume)