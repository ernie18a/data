Calculation: Bull score = max(0, min(100, 2 × (floor(100 × count of bars with Bulls Power > 0 over the lookback) − 50))); Bulls Power = high − EMA of close. Calculate on chart bars or on higher-timeframe bars using the still-forming higher-timeframe bar.
Calculation: Bear score = max(0, min(100, 2 × (floor(100 × count of bars with Bears Power < 0 over the same lookback) − 50))); Bears Power = low − EMA of close with the same period as Bulls Power. Use the same timeframe and bar as the bull score.
Long: Bull score > bear score
Short: Bear score > bull score