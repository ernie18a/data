Calculation: relative volume = volume / SMA(volume, shorter lookback)
Calculation: stop distance = ATR multiplied by a stop multiplier; first target distance = stop distance multiplied by a target fraction
Long: ATR > longer-lookback SMA(ATR) multiplied by a volatility threshold AND EMA(shorter) > EMA(medium) AND EMA(medium) > EMA(longer) AND low <= EMA(shortest) AND RSI > upper threshold AND close > open AND relative volume > threshold
Short: ATR > longer-lookback SMA(ATR) multiplied by a volatility threshold AND EMA(shorter) < EMA(medium) AND EMA(medium) < EMA(longer) AND high >= EMA(shortest) AND RSI < lower threshold AND close < open AND relative volume > threshold
Exit: long, low <= entry price - stop distance OR high >= entry price + first target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - first target distance