Calculation: PPO = 100 × (shorter-lookback moving average of selected price source − longer-lookback moving average of the same source) / longer-lookback moving average; use the same SMA or EMA type for both.
Calculation: Signal = SMA or EMA of PPO, using the same moving-average type as PPO.
Calculation: Histogram = PPO − Signal.
Calculation: Entry risk = ATR on the signal bar × stop-distance multiplier; the recorded entry price is the previous chart bar’s close. Keep entry risk fixed until the next entry signal.
Long: PPO crosses above Signal AND, if enabled, PPO on the last completed higher-timeframe bar > 0 AND, if enabled, ADX >= its threshold AND, if enabled, ATR >= SMA of ATR over the same lookback × volatility multiplier AND, if enabled, volume >= SMA of volume × volume multiplier AND, if enabled, Histogram > every Histogram value in the preceding slope-lookback bars.
Short: PPO crosses below Signal AND, if enabled, PPO on the last completed higher-timeframe bar < 0 AND, if enabled, ADX >= its threshold AND, if enabled, ATR >= SMA of ATR over the same lookback × volatility multiplier AND, if enabled, volume >= SMA of volume × volume multiplier AND, if enabled, Histogram < every Histogram value in the preceding slope-lookback bars.
Long: PPO crosses above 0.
Short: PPO crosses below 0.
Long: PPO >= 0 OR Signal >= 0 OR Histogram >= 0 OR PPO > Signal.
Short: PPO < 0 OR Signal < 0 OR Histogram < 0 OR PPO < Signal.
Long: Higher-timeframe confirmation is enabled AND PPO on the last completed higher-timeframe bar > 0.
Short: Higher-timeframe confirmation is enabled AND PPO on the last completed higher-timeframe bar <= 0.
Exit: long, high >= entry price + entry risk × a take-profit multiplier.
Exit: short, low <= entry price − entry risk × a take-profit multiplier.