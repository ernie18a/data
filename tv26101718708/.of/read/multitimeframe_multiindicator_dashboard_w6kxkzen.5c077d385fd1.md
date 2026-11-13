Calculation: TF value = indicator computed on bars aggregated to each of several fixed timeframes (some lower and some higher than the chart timeframe), read at each chart bar from that timeframe's still-forming bar (its close = latest price so far). Each timeframe and each indicator below is evaluated independently, and each gives its own long or short mark.
Long: TF close > SMA(TF close, N) for each of several SMA lengths N, from short-term to long-term
Long: RSI(TF close) > 50
Long: MACD histogram (MACD line minus signal line, MACD line = fast EMA minus slow EMA of TF close, fast lookback shorter than slow) > 0
Long: SuperTrend (ATR-based trailing band) on the TF is in uptrend, i.e. price above the band
Long: any Long condition above is true on the current chart bar and was false (Bearish) on the previous chart bar
Short: TF close <= SMA(TF close, N) for each of the same several SMA lengths N
Short: RSI(TF close) < 50
Short: MACD histogram < 0
Short: SuperTrend on the TF is in downtrend, i.e. price below the band
Short: any Short condition above is true on the current chart bar and was false (Bullish) on the previous chart bar