Calculation: Order-flow pressure percentage = 100 × (2 × close − high − low) / (high − low); use zero when volume is zero or high equals low.
Calculation: Bullish MACD divergence = at the confirmation bar, price low and MACD histogram both have pivots at the same bar using the same number of bars on each side, and that price pivot is below the preceding simultaneously confirmed price-low pivot while that histogram pivot is above its paired predecessor.
Calculation: Bearish MACD divergence = at the confirmation bar, price high and MACD histogram both have pivots at the same bar using the same number of bars on each side, and that price pivot is above the preceding simultaneously confirmed price-high pivot while that histogram pivot is below its paired predecessor.
Long: Close < close at the arrival lookback.
Short: Close > close at the arrival lookback.
Long: Order-flow pressure percentage > positive pressure threshold.
Short: Order-flow pressure percentage < negative pressure threshold.
Long: Supertrend direction is bullish.
Short: Supertrend direction is bearish.
Long: Bullish MACD divergence, with the optional level-proximity restriction disabled.
Short: Bearish MACD divergence, with the optional level-proximity restriction disabled.
Exit: long, close >= exit EMA AND the preceding bar did not satisfy this exit condition.
Exit: short, close <= exit EMA AND the preceding bar did not satisfy this exit condition.
Exit: long, high >= entry price + current ATR × target multiplier.
Exit: short, low <= entry price − current ATR × target multiplier.