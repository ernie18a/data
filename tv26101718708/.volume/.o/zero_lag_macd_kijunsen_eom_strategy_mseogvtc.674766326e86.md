Calculation: Zero Lag MACD = (2 × moving average of close over the fast lookback − moving average of that moving average over the fast lookback) − (2 × moving average of close over the longer, slow lookback − moving average of that moving average over the slow lookback); use EMA or SMA as configured
Calculation: Signal line = zero-lag double EMA of Zero Lag MACD over the signal lookback, or its SMA over that lookback when the alternate algorithm is selected
Calculation: Kijun-sen = (highest high + lowest low) / 2 over its lookback
Calculation: Ease of Movement = moving average over its lookback of [divisor × change in (high + low) / 2 × (high − low) / volume]
Calculation: Long stop = entry price − ATR × stop multiplier
Calculation: Long target = entry price + (entry price − long stop) × reward ratio
Calculation: Short stop = entry price + ATR × stop multiplier
Calculation: Short target = entry price − (short stop − entry price) × reward ratio
Long: Zero Lag MACD crosses above the signal line (current Zero Lag MACD > current signal line AND previous Zero Lag MACD ≤ previous signal line) AND Zero Lag MACD < Zero Lag MACD − signal line AND close > Kijun-sen AND Ease of Movement > 0
Short: Zero Lag MACD crosses below the signal line (current Zero Lag MACD < current signal line AND previous Zero Lag MACD ≥ previous signal line) AND Zero Lag MACD > Zero Lag MACD − signal line AND close < Kijun-sen AND Ease of Movement < 0
Exit: long, low ≤ long stop OR high ≥ long target
Exit: short, high ≥ short stop OR low ≤ short target