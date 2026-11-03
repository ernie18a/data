Calculation: Choppiness Index = 100 × log(sum of true range over the lookback ÷ (highest high − lowest low over the lookback)) ÷ log(lookback)
Long: datetime is within the configured trading session AND Choppiness Index < threshold AND OBV > its EMA
Short: datetime is within the configured trading session AND Choppiness Index < threshold AND OBV < its EMA
Exit: long, low ≤ close − ATR × exit multiplier OR high ≥ entry price + ATR × exit multiplier
Exit: short, high ≥ close + ATR × exit multiplier OR low ≤ entry price − ATR × exit multiplier