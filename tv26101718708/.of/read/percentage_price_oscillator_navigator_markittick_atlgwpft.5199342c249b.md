Calculation: PPO = 100 × (shorter-lookback moving average of close − longer-lookback moving average of close) / longer-lookback moving average of close
Calculation: Signal line = moving average of PPO
Calculation: Histogram = PPO − Signal line
Calculation: Higher-timeframe PPO = PPO on a higher timeframe, using the last completed bar
Calculation: ATR volatility average = moving average of ATR, using the same lookback as ATR
Long: PPO crosses above Signal line AND (if enabled) Higher-timeframe PPO > 0 AND (if enabled) ADX ≥ its threshold AND (if enabled) ATR ≥ ATR volatility average × its multiplier AND (if enabled) volume ≥ its moving average × its multiplier AND (if enabled) Histogram is rising for the configured number of bars
Short: PPO crosses below Signal line AND (if enabled) Higher-timeframe PPO < 0 AND (if enabled) ADX ≥ its threshold AND (if enabled) ATR ≥ ATR volatility average × its multiplier AND (if enabled) volume ≥ its moving average × its multiplier AND (if enabled) Histogram is falling for the configured number of bars
Long: PPO crosses above 0
Short: PPO crosses below 0
Exit: Long, PPO crosses below Signal line AND the short-entry filters pass
Exit: Short, PPO crosses above Signal line AND the long-entry filters pass
Exit: Long, high ≥ entry price + ATR-based stop distance × any configured take-profit risk:reward multiple
Exit: Short, low ≤ entry price − ATR-based stop distance × any configured take-profit risk:reward multiple