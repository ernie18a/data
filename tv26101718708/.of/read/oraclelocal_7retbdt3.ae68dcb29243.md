Calculation: Relative volume = volume / SMA(volume).
Calculation: Money flow ratio = SMA(volume × ((close − low) − (high − close)) / max(high − low, epsilon)) / SMA(volume), using the same lookback in both SMAs.
Calculation: Trend score = 2 if close > EMA(close), otherwise 0, plus 2 if EMA(close) > its previous value, otherwise 0, plus 1 if the MACD line > its signal line, otherwise 0.
Calculation: Strength score = 5, 4, 3, 2, or 1 as ADX is respectively at or above the highest, next-highest, next-lowest, or lowest of four ordered thresholds, or below the lowest threshold.
Calculation: Momentum score = min(5, RSI points + rate-of-change points + stochastic %K points), where RSI points and close rate-of-change points each equal 2 at or above their upper threshold, 1 at or above their lower threshold, and 0 otherwise; stochastic points equal 1 when %K is at or above its threshold and 0 otherwise.
Calculation: Crowd score = min(5, relative-volume points + money-flow-ratio points + OBV points), where relative-volume points equal 2 at or above their upper threshold, 1 at or above their lower threshold, and 0 otherwise; money-flow-ratio points equal 2 above their upper threshold, 1 above their lower threshold, and 0 otherwise; OBV points equal 1 if OBV > its previous value and 0 otherwise.
Calculation: Flow score = round(clamp((MFI points + money-flow-ratio points + VWAP points + 5) / 2, 0, 5)), where MFI points equal 2 at or above an upper threshold, 1 at or above a lower threshold, −2 at or below a lower negative-point threshold, −1 at or below a higher negative-point threshold, and 0 otherwise; money-flow-ratio points equal 2 above a positive threshold, 1 above zero, −2 below a negative threshold, −1 below zero, and 0 otherwise; VWAP points equal 1 if close > session VWAP of close and −1 otherwise. Calculate MFI from close and volume.
Calculation: Overall score = round(100 × (trend score + strength score + momentum score + crowd score + flow score) / 25).
Long: Position is flat at the start of the bar AND close > EMA(close) AND RSI(close) > an upper entry threshold AND relative volume >= its entry threshold AND EMA(close) > its previous value.
Short: Position is flat at the start of the bar AND close < EMA(close) AND RSI(close) < a lower entry threshold AND relative volume >= its entry threshold AND EMA(close) < its previous value.
Exit: long, close < EMA(close) OR (RSI(close) < its exit threshold AND previous RSI(close) >= that threshold).
Exit: short, close > EMA(close) OR (RSI(close) > its exit threshold AND previous RSI(close) <= that threshold).
Long: close > EMA(close).
Short: close <= EMA(close).
Long: overall score >= its upper threshold.
Short: overall score < its lower threshold.