Calculation: Choppiness Index = 100 × log10(sum of True Range over the lookback / (highest high − lowest low over the lookback)) / log10(lookback)
Calculation: ATR percentage = ATR / close × 100, captured on the entry trigger bar
Calculation: Long take-profit = fill price × (1 + ATR percentage × take-profit multiplier / 100)
Calculation: Long stop = max(fill price × (1 − ATR percentage × stop-loss multiplier / 100), fill price × (1 − hard-stop percentage / 100))
Calculation: Short take-profit = fill price × (1 − ATR percentage × take-profit multiplier / 100)
Calculation: Short stop = min(fill price × (1 + ATR percentage × stop-loss multiplier / 100), fill price × (1 + hard-stop percentage / 100))
Long: Long direction is enabled AND flat AND (no prior exit OR bars since last exit >= cooldown) AND MACD crosses its signal line in either direction AND MACD histogram < 0 AND low <= VWMA AND Choppiness Index < threshold AND ADX > threshold
Short: Short direction is enabled AND flat AND (no prior exit OR bars since last exit >= cooldown) AND MACD crosses its signal line in either direction AND MACD histogram > 0 AND high >= VWMA AND Choppiness Index < threshold AND ADX > threshold
Exit: Long, high >= long take-profit OR low <= long stop
Exit: Short, low <= short take-profit OR high >= short stop