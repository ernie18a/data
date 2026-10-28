Calculation: Choppiness Index = 100 × log(sum of true range over the lookback ÷ (highest high − lowest low over the lookback)) ÷ log(lookback)
Long: within the configured session AND Choppiness Index < threshold AND OBV > its EMA
Short: within the configured session AND Choppiness Index < threshold AND OBV < its EMA
Exit: long, low ≤ current close − ATR × multiplier OR high ≥ entry price + ATR × multiplier
Exit: short, high ≥ current close + ATR × multiplier OR low ≤ entry price − ATR × multiplier