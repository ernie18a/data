Calculation: session open price = open of the latest selected-session start, or current open if none exists
Calculation: raw strength = (range weight * (ATR(ATR lookback) > 0 ? 100 * min((high - low) / ATR(ATR lookback), range cap) / range cap : 0) + volume weight * (SMA(volume, volume lookback) > 0 ? 100 * min(volume / SMA(volume, volume lookback), relative-volume cap) / relative-volume cap : 0) + body weight * (high > low ? 100 * abs(close - open) / (high - low) : 0) + displacement weight * (ATR(ATR lookback) > 0 ? 100 * min(abs(close - session open price) / ATR(ATR lookback), displacement cap) / displacement cap : 0)) / max(range weight + volume weight + body weight + displacement weight, minimum weight total)
Calculation: signed strength = EMA(raw strength, strength smoothing lookback) * clamp(bar-bias weight * sign(close - open) + session-open-bias weight * sign(close - session open price), -1, 1)
Long: close > selected-session opening-range high
Long: signed strength >= strong threshold
Long: signed strength > weak threshold AND signed strength < strong threshold
Long: signed strength crosses above strong threshold
Long: signed strength crosses above zero
Short: close < selected-session opening-range low
Short: signed strength <= -strong threshold
Short: signed strength < -weak threshold AND signed strength > -strong threshold
Short: signed strength crosses below -strong threshold
Short: signed strength crosses below zero