Calculation: Bullish trend = fast EMA > base EMA > slow EMA AND (base EMA − base EMA from the slope lookback bars ago) / ATR > positive slope threshold
Calculation: Bearish trend = fast EMA < base EMA < slow EMA AND (base EMA − base EMA from the slope lookback bars ago) / ATR < negative slope threshold
Calculation: Acceptance pocket = base EMA ± ATR × pocket-width parameter
Calculation: Recent pocket touch = current bar overlaps the acceptance pocket OR a bar within the pullback review window overlapped it
Calculation: Bullish acceptance close = close > pocket top + ATR × close-buffer parameter
Calculation: Bearish acceptance close = close < pocket bottom − ATR × close-buffer parameter
Calculation: Risk shelf = bullish: min(pocket bottom, slow EMA) − ATR × risk-buffer parameter; bearish: max(pocket top, slow EMA) + ATR × risk-buffer parameter
Calculation: Pullback depth = bullish: max((fast EMA − lowest low in review window) / ATR, 0); bearish: max((highest high in review window − fast EMA) / ATR, 0)
Calculation: Target room = distance in the trend direction from close to the nearest prior obstruction (highest high for bullish, lowest low for bearish) over the target lookback, divided by ATR; if the obstruction is missing or less than 0.20 ATR away, use the clean-room parameter as the distance
Calculation: Relative volume = volume / SMA(volume, volume-baseline lookback)
Calculation: Acceptance score = clamp to 0–100 the weighted sum of depth score × 0.22 + close score × 0.24 + trend score × 0.20 + volume score × 0.14 + risk score × 0.12 + room score × 0.08. Depth score peaks at the ideal pullback depth and declines toward the shallow and deep-risk limits. Close score increases with close distance beyond the pocket edge, using a higher-good linear normalization; trend score increases with ATR-normalized base-EMA slope magnitude; volume score uses higher-good normalization of relative volume on an acceptance close and lower-good normalization otherwise; risk score peaks at the ideal risk distance and declines toward its lower and upper limits; room score increases with target room. Linear normalization maps the stated weak and strong bounds to 0 and 100, clamped to that range.
Long: bullish trend AND recent pocket touch AND bullish acceptance close AND acceptance score ≥ accepted threshold
Short: bearish trend AND recent pocket touch AND bearish acceptance close AND acceptance score ≥ accepted threshold
Exit: long, close < risk shelf
Exit: short, close > risk shelf