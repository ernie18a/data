Calculation: High-volume bar = volume > SMA(volume, volume-average lookback) × volume-spike factor
Calculation: Wide-spread bar = high − low > SMA(high − low, spread-average lookback) × wide-spread factor
Calculation: Bullish VPA bar = close > open AND high-volume bar AND wide-spread bar
Calculation: Bearish VPA bar = close < open AND high-volume bar AND wide-spread bar
Calculation: Real body = abs(close − open)
Calculation: EMA percentage slope = 100 × (EMA(close, long-term lookback) − EMA(close, long-term lookback)[slope lag]) / EMA(close, long-term lookback)[slope lag]
Calculation: Descending pivot-high trendline = the line through the two latest confirmed pivot highs, each confirmed using pivot-strength lookback bars on both sides, when the latest pivot high is below the previous one, extended to the current bar
Calculation: Long trailing stop = while long, max(previous trailing stop or zero, close − ATR(ATR lookback) × ATR factor); reset when flat
Long: Bullish VPA bar AND a descending pivot-high trendline exists AND close crosses above the trendline AND EMA percentage slope > minimum entry slope
Long: A descending pivot-high trendline exists AND close crosses above the trendline
Long: min(open, close) − low > real body × wick-to-body factor AND high-volume bar
Long: EMA percentage slope > 0
Long: RSI(close, RSI lookback) < oversold threshold
Short: Bearish VPA bar
Short: high − max(open, close) > real body × wick-to-body factor AND high-volume bar
Short: EMA percentage slope <= 0
Short: RSI(close, RSI lookback) > overbought threshold
Exit: Long, close < long trailing stop OR bearish VPA bar