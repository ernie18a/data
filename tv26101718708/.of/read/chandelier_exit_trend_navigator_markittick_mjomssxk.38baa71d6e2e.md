Calculation: Adaptive close = optionally close, a Kalman estimate, or a slope-adjusted average. For the Kalman estimate, initialize the estimate to the first close and error to 1; on each bar set predicted error = error + 1 / filter length, gain = predicted error / (predicted error + 1), estimate = estimate + gain × (close - estimate), and error = (1 - gain) × predicted error. For the slope-adjusted average, use SMA(close, filter length) + (close - close filter length bars ago) / 2.
Calculation: Upper boundary = highest adaptive close over the ATR lookback - ATR × multiplier when close extremes are selected; otherwise highest high over the ATR lookback - ATR × multiplier.
Calculation: Lower boundary = lowest adaptive close over the ATR lookback + ATR × multiplier when close extremes are selected; otherwise lowest low over the ATR lookback + ATR × multiplier.
Calculation: Trend = bullish on the first bar if close >= open, otherwise bearish; on subsequent bars bullish if close > previous lower boundary, otherwise bearish if close < previous upper boundary, otherwise unchanged.
Calculation: Higher-timeframe EMA = EMA of higher-timeframe closes, using the last completed higher-timeframe bar.
Long: Trend = bullish.
Short: Trend = bearish.
Long: Higher-timeframe filter enabled AND close > higher-timeframe EMA.
Short: Higher-timeframe filter enabled AND close < higher-timeframe EMA.
Long: Trend = bullish AND previous trend = bearish AND (higher-timeframe filter disabled OR close > higher-timeframe EMA) AND (ADX filter disabled OR ADX >= threshold).
Short: Trend = bearish AND previous trend = bullish AND (higher-timeframe filter disabled OR close < higher-timeframe EMA) AND (ADX filter disabled OR ADX >= threshold).
Exit: long, trend = bearish AND previous trend = bullish AND (higher-timeframe filter disabled OR close < higher-timeframe EMA) AND (ADX filter disabled OR ADX >= threshold).
Exit: short, trend = bullish AND previous trend = bearish AND (higher-timeframe filter disabled OR close > higher-timeframe EMA) AND (ADX filter disabled OR ADX >= threshold).