Calculation: Shorter-lookback SMMA = recursively smoothed average of (high + low) / 2, initialized with its simple moving average; each next value is (previous value × (lookback − 1) + current value) / lookback
Calculation: Longer-lookback SMMA = same calculation as the shorter-lookback SMMA, using a longer lookback
Long: (close > open AND UO crossed above its oversold threshold or lower entry threshold within the current or previous three bars AND shorter-lookback SMMA > longer-lookback SMMA) OR (position is long AND close < entry price AND UO crosses above the add threshold)
Exit: Long, take-profit option enabled AND close > entry price AND UO crosses below its take-profit threshold (partial exit)
Exit: Long, UO crosses below its overbought threshold
Exit: Long, close < entry price × (1 − stop-loss fraction) AND UO < its overbought threshold