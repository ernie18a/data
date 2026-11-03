Calculation: Volume delta = volume when close > open, -volume when close < open, and 0 otherwise.
Long: On each selected higher or lower timeframe, short-period EMA of close > long-period EMA of close.
Short: On each selected higher or lower timeframe, short-period EMA of close <= long-period EMA of close.
Long: On each selected higher or lower timeframe, RSI > its midpoint OR RSI > previous-bar RSI OR MACD line > 0 OR MACD line > previous-bar MACD line.
Short: On each selected higher or lower timeframe, RSI <= its midpoint OR RSI < previous-bar RSI OR MACD line <= 0 OR MACD line < previous-bar MACD line.
Calculation: Higher-timeframe calculations use the bar still forming; lower-timeframe calculations use the last available lower-timeframe bar within the chart bar.
Long: OBV > previous-bar OBV OR SMA of volume > its previous-bar value.
Short: OBV <= previous-bar OBV OR SMA of volume <= its previous-bar value.
Long: Stochastic %K > its midpoint OR close > session VWAP OR shorter-period EMA of close > longer-period EMA of close OR close > EMA of close OR RSI > previous-bar RSI OR EMA of close > its previous-bar value OR SMA of volume delta > 0.
Short: Stochastic %K <= its midpoint OR close <= session VWAP OR shorter-period EMA of close <= longer-period EMA of close OR close <= EMA of close OR RSI <= previous-bar RSI OR EMA of close <= its previous-bar value OR SMA of volume delta <= 0.
Long: Close > shorter-period EMA of close AND shorter-period EMA of close > longer-period EMA of close AND close > session VWAP.
Short: Close < shorter-period EMA of close AND shorter-period EMA of close < longer-period EMA of close AND close < session VWAP.
Long: Shorter-period EMA of close > longer-period EMA of close AND absolute difference between those EMAs >= ATR multiplied by a range threshold.
Short: Shorter-period EMA of close < longer-period EMA of close AND absolute difference between those EMAs >= ATR multiplied by a range threshold.