Long: daily close > daily 20-period EMA AND daily close > daily 50-period EMA AND daily MACD histogram > 0 AND (close <= 20-period EMA OR close <= Bollinger middle band) AND RSI > 45 AND (MACD histogram > 0 OR MACD line > MACD signal line)
Calculation: Long stop = signal bar close - 1.5 × ATR
Calculation: Long target = signal bar close + 2 × (signal bar close - Long stop)
Exit: Long, low <= Long stop OR high >= Long target