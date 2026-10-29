Calculation: Monthly VWAP = sum(low × volume) from the start of the current month through the current bar, divided by the same bars’ summed volume
Calculation: SMO oscillator = TSI of close using shorter and longer lookbacks, minus an EMA of that TSI using a separate signal lookback
Long: close > Monthly VWAP AND MACD histogram > previous bar’s MACD histogram AND SMO oscillator > 0
Short: close < Monthly VWAP AND MACD histogram < previous bar’s MACD histogram AND SMO oscillator < 0
Exit: Long, low ≤ entry price − close × long stop-loss percentage OR high ≥ entry price + close × long take-profit percentage OR close < Monthly VWAP AND MACD histogram < previous bar’s MACD histogram AND SMO oscillator < 0
Exit: Short, high ≥ entry price + close × short stop-loss percentage OR low ≤ entry price − close × short take-profit percentage OR close > Monthly VWAP AND MACD histogram > previous bar’s MACD histogram AND SMO oscillator > 0