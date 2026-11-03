Calculation: Timeframe values = calculate indicators on each selected timeframe; for a higher timeframe use the last completed bar on historical chart bars and the still-forming bar in real time; for a lower timeframe use the last completed intrabar within the chart bar.
Calculation: Bullish trend = slow EMA > longest-term EMA AND (fast EMA crosses above medium EMA OR fast EMA crosses above slow EMA OR (fast EMA > medium EMA AND fast EMA > slow EMA)) AND (MFI filter disabled OR MFI > bullish threshold) AND (RSI filter disabled OR RSI > bullish threshold) AND (ADX filter disabled OR ADX > strength threshold) AND (MACD filter disabled OR MACD line > signal line) AND (VWAP filter disabled OR close > anchored VWAP). EMA lengths increase from fast to medium to slow to longest-term; all EMAs use the selected source. MACD uses a shorter and a longer moving average of its selected source, with independently selectable EMA or SMA for its signal average. VWAP uses the selected source and resets at the selected anchor period.
Calculation: Bearish trend = slow EMA < longest-term EMA AND (fast EMA crosses below medium EMA OR fast EMA crosses below slow EMA OR (fast EMA < medium EMA AND fast EMA < slow EMA)) AND (MFI filter disabled OR MFI < bearish threshold) AND (RSI filter disabled OR RSI < bearish threshold) AND (ADX filter disabled OR ADX > strength threshold) AND (MACD filter disabled OR MACD line < signal line) AND (VWAP filter disabled OR close < anchored VWAP).
Calculation: Consensus score = sum across the selected core timeframes of +1 for bullish trend, -1 for bearish trend, and 0 otherwise; if both trends occur on the same timeframe, give crossover conditions priority over sustained trend conditions.
Long: Bullish trend = true.
Short: Bearish trend = true AND bullish crossover condition = false.
Long: Consensus score >= strict majority of the number of core timeframes.
Short: Consensus score <= negative strict majority of the number of core timeframes.
Long: RSI >= bullish threshold.
Short: RSI < bullish threshold AND RSI <= bearish threshold.
Long: MFI >= bullish threshold.
Short: MFI < bullish threshold AND MFI <= bearish threshold.
Long: MACD line > signal line OR (MACD line >= 0 AND MACD line = signal line).
Short: MACD line < signal line OR (MACD line < 0 AND MACD line = signal line).
Long: close > anchored VWAP.
Short: close <= anchored VWAP.