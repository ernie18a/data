Calculation: HTF = all indicators below use bars of a timeframe higher than the chart timeframe, taking the last completed HTF bar, not the one still forming; the chart-timeframe close, high and low are used only where stated as chart values.
Calculation: ATR = Wilder-smoothed (RMA) true range of HTF bars
Calculation: MACD = EMA(HTF close, short lookback) - EMA(HTF close, long lookback); signal line = EMA of MACD
Calculation: MFI = Money Flow Index on HTF hlc3 and HTF volume; oversold level = fixed low threshold
Long: EMA(HTF close, n) > SMA(HTF close, same n) AND (MACD crosses above its signal line OR MFI crosses above its oversold level) AND (optional filter) RSI(HTF close) < fixed threshold AND (optional filter) chart close > SMA(HTF close, short lookback)
Exit: long, chart close < entry price - multiplier * ATR, where entry price = chart close of the bar where the long condition was met
Exit: long, highest high since entry >= entry price * (1 + p) AND chart low <= highest high since entry - entry price * p
Exit: long, (optional partial exit) chart high >= entry price * (1 + q)