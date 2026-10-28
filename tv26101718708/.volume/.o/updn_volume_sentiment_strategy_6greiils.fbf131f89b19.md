Calculation: Up volume = volume when close > previous close, otherwise 0
Calculation: Down volume = volume when close < previous close, otherwise 0
Calculation: Up/down volume ratio = simple moving average of up volume / simple moving average of down volume, using the same lookback
Calculation: Sentiment oscillator = 100 × (up/down volume ratio − its lowest value over the normalization lookback) / (its highest value over the normalization lookback − its lowest value over the normalization lookback)
Long: Sentiment oscillator ≤ long-entry threshold
Short: Sentiment oscillator ≥ short-entry threshold
Exit: long, low ≤ entry price × (1 − stop-loss percentage) OR high ≥ entry price × (1 + stop-loss percentage × profit-target multiple)
Exit: short, high ≥ entry price × (1 + stop-loss percentage) OR low ≤ entry price × (1 − stop-loss percentage × profit-target multiple)