Calculation: Per-bar volume delta = ((close - open) / (high - low)) × volume when high ≠ low; otherwise 0
Calculation: Cumulative volume delta = cumulative sum of per-bar volume delta
Calculation: Price Z-score = change in close over the configured trend lookback / standard deviation of that change over a longer lookback
Calculation: Cumulative volume delta Z-score = change in cumulative volume delta over the configured trend lookback / standard deviation of that change over the same longer lookback
Calculation: Order-flow score = clamp((HMA of price Z-score + HMA of cumulative volume delta Z-score) × configured scale, to the configured score bounds)
Calculation: Dynamic entry threshold = configured base threshold × configured session multiplier during the configured session; otherwise the configured base threshold
Calculation: Macro upper band = chart-timeframe EMA + chart-timeframe ATR × configured band multiplier
Calculation: Macro lower band = chart-timeframe EMA − chart-timeframe ATR × configured band multiplier
Calculation: Daily price change = current daily close − prior completed daily close; daily open-interest change = current daily open interest − prior completed daily open interest. Use the still-forming daily bar for current values.
Calculation: Daily open-interest Z-score = (current daily open interest − 20-bar SMA) / 20-bar standard deviation, calculated on the chart timeframe using the daily series
Calculation: Open-interest climax = daily open-interest Z-score > configured climax threshold
Long: Order-flow score crosses above dynamic entry threshold AND (macro filter disabled OR close > macro upper band) AND (open-interest filter disabled OR (daily price change > 0 AND daily open-interest change > 0) OR (daily price change < 0 AND daily open-interest change < 0))
Short: Order-flow score crosses below −dynamic entry threshold AND (macro filter disabled OR close < macro lower band) AND (open-interest filter disabled OR (daily price change < 0 AND daily open-interest change > 0))
Exit: long, order-flow score crosses below −configured base threshold OR close crosses below macro lower band OR (open-interest climax AND order-flow score < 0) OR low ≤ entry price − ATR at entry × configured stop multiplier
Exit: short, order-flow score crosses above configured base threshold OR close crosses above macro upper band OR (open-interest climax AND order-flow score > 0) OR high ≥ entry price + ATR at entry × configured stop multiplier