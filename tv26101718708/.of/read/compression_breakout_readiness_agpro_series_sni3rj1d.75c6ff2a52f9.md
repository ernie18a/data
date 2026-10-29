Calculation: Range position = clamp((close − lowest low over the compression lookback) / (highest high over the compression lookback − lowest low over the compression lookback), 0, 1)
Calculation: Candle pressure = 2 × ((close − low) / max(high − low, minimum tick)) − 1
Calculation: EMA bias = 1 when the short-term EMA is above the long-term EMA and the long-term EMA is above its value several bars earlier; −1 when both comparisons are reversed; otherwise 0
Calculation: Midpoint bias = clamp((midpoint of the recent half-lookback high-low range − midpoint of the preceding half-lookback high-low range) / ATR, −1, 1)
Calculation: Directional bias = clamp(0.38 × (2 × range position − 1) + 0.27 × EMA bias + 0.20 × candle pressure + 0.15 × midpoint bias, −1, 1)
Long: Directional bias ≥ the auto-side-bias threshold
Short: Directional bias ≤ −the auto-side-bias threshold