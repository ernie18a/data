Long: close > highest high of the preceding entry lookback bars (excluding the current bar) AND close > EMA AND RSI > 50 AND ATR > its moving average
Short: close < lowest low of the preceding entry lookback bars (excluding the current bar) AND close < EMA AND RSI < 50 AND ATR > its moving average
Calculation: Long ATR stop = signal-bar close − ATR × stop multiplier; set when the long entry condition is met and retain until updated
Calculation: Short ATR stop = signal-bar close + ATR × stop multiplier; set when the short entry condition is met and retain until updated
Exit: Long, close < lowest low of the preceding exit lookback bars (excluding the current bar) OR low ≤ Long ATR stop
Exit: Short, close > highest high of the preceding exit lookback bars (excluding the current bar) OR high ≥ Short ATR stop