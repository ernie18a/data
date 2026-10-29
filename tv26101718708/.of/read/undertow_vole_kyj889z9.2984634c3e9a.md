Calculation: Loud index = prior loud index × (1 + close-to-close return) when volume increases; otherwise unchanged. Quiet index = prior quiet index × (1 + close-to-close return) when volume decreases; otherwise unchanged. Initialize both at 1. Use volume, or the absolute most recent nonzero candle-body move in ticks when volume is zero.
Calculation: Loud oscillator = 100 × (loud index − its EMA) / (highest − lowest of that EMA over the same recent range). Quiet oscillator = the same calculation using the quiet index. Use the same smoothing and range lookbacks for both.
Calculation: Trend = (RSI + MFI + normalized Bollinger-band displacement + stochastic position / 3) / 2.
Calculation: Crowd = trend + loud oscillator.
Calculation: Trend average = EMA of trend.
Long: quiet oscillator crosses above trend average AND quiet oscillator > 0 AND crowd < 0 AND close > open AND the most recently fired event is not long
Short: quiet oscillator crosses below 0 AND crowd > trend AND crowd > trend average AND quiet oscillator < trend average AND close < open AND the most recently fired event is not short
All calculations use chart-timeframe bars and signals are evaluated on completed bars.