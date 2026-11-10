Calculation: Regression slope = linear regression of close over the trend lookback, evaluated at the current bar, minus the same regression evaluated one bar earlier using the same current window.
Calculation: Confirmed pivot high or low = a high or low confirmed after an equal number of bars on each side; use its value only from the confirmation bar onward.
Calculation: Volume ratio = current volume divided by the simple moving average of volume, including the current bar.
Long: close > short-period EMA of close OR close > medium-period EMA of close OR close > long-period EMA of close.
Long: short-period EMA of close > medium-period EMA of close.
Long: RSI > midpoint threshold AND RSI < upper bullish threshold.
Long: regression slope > 0.
Long: close > highest high over the trend lookback ending on the previous bar.
Long: low > lowest low over the trend lookback ending on the previous bar AND that previous-bar lowest low > the lowest low over the trend lookback ending one trend lookback before the current bar.
Long: volume ratio > high-volume threshold AND close > open.
Long: close > open AND previous close < previous open AND close > previous open AND open < previous close.
Long: min(open, close) - low > wick multiplier × abs(close - open) AND high - max(open, close) < abs(close - open) AND close > open.
Long: a pivot low is confirmed on the current bar AND abs(latest confirmed pivot low - preceding confirmed pivot low) / preceding confirmed pivot low < pivot similarity threshold.
Long: low < low at the divergence lookback AND RSI > RSI at the divergence lookback AND RSI < bullish divergence threshold.
Long: close > highest high over the breakout lookback ending on the previous bar AND previous close <= that same highest high AND volume ratio > breakout-volume threshold.
Short: close < short-period EMA of close OR close < medium-period EMA of close OR close < long-period EMA of close.
Short: short-period EMA of close < medium-period EMA of close.
Short: RSI < midpoint threshold AND RSI > lower bearish threshold.
Short: RSI > overbought threshold.
Short: regression slope < 0.
Short: close < lowest low over the trend lookback ending on the previous bar.
Short: volume ratio > high-volume threshold AND close < open.
Short: close < open AND previous close > previous open AND close < previous open AND open > previous close.
Short: high - max(open, close) > wick multiplier × abs(close - open) AND min(open, close) - low < abs(close - open) AND close < open.
Short: a pivot high is confirmed on the current bar AND abs(latest confirmed pivot high - preceding confirmed pivot high) / preceding confirmed pivot high < pivot similarity threshold.
Short: high > high at the divergence lookback AND RSI < RSI at the divergence lookback AND RSI > bearish divergence threshold.
Short: close < lowest low over the breakout lookback ending on the previous bar AND previous close >= that same lowest low AND volume ratio > breakout-volume threshold.