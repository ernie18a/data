Calculation: Fast EMA = exponential moving average of close with a shorter lookback than the Slow EMA
Calculation: Slow EMA = exponential moving average of close with a longer lookback than the Fast EMA
Calculation: Absorption = volume > average volume × volume multiplier AND abs(close − open) < a fraction of the high − low range
Calculation: Delta = (close − open) ÷ (high − low) × volume
Calculation: Accumulation = Absorption AND (Delta > 0 OR close > VWAP)
Calculation: Distribution = Absorption AND (Delta < 0 OR close < VWAP)
Long: Fast EMA crosses above Slow EMA OR Accumulation
Short: Fast EMA crosses below Slow EMA OR Distribution