Calculation: Close position = (close − low) / (high − low)
Calculation: Normalized volume = volume / its simple moving average, capped at 3; use 1 if the average is not positive
Calculation: Flow score = normalize (body size / bar range × normalized volume) to 0–1 using its rolling lowest and highest values; use 0 if they are equal
Long: close > weighted moving average
Long: close > weighted moving average AND previous close ≤ previous weighted moving average
Long: close < weighted moving average AND close position > 0.65 AND close > open AND normalized volume > 1.2 AND flow score > 0.5
Short: close < weighted moving average
Short: close < weighted moving average AND previous close ≥ previous weighted moving average
Short: close > weighted moving average AND close position < 0.35 AND close < open AND normalized volume > 1.2 AND flow score > 0.5