Calculation: T1 MACD line and signal line = MACD(T1 close, fast lookback, slow lookback, signal lookback), calculated on chart bars from the mapped T1 close; uses the last completed T1 bar historically and the still-forming T1 bar in realtime
Calculation: AC = Accelerator Oscillator(hl2, shorter lookback, longer lookback, smoothing lookback)
Calculation: ATR = ATR(high, low, close, lookback)
Long: T1 MACD line > T1 MACD signal line AND AC crosses above 0
Short: T1 MACD line < T1 MACD signal line AND AC crosses below 0
Exit: Long, low <= entry price - ATR * stop-loss multiple OR high >= entry price + ATR * take-profit multiple
Exit: Short, high >= entry price + ATR * stop-loss multiple OR low <= entry price - ATR * take-profit multiple