Calculation: Normalized ATR = (current ATR − lowest ATR over the ATR lookback) / (highest ATR over the ATR lookback − lowest ATR over the ATR lookback)
Calculation: Dynamic overbought level = min(100, base overbought level + normalized ATR × (100 − base overbought level) × ATR scaling factor)
Calculation: Dynamic oversold level = max(0, base oversold level − normalized ATR × base oversold level × ATR scaling factor)
Long: RSI crosses below the dynamic oversold level AND the shorter-lookback moving average of close is greater than or equal to the longer-lookback moving average of close
Short: RSI crosses above the dynamic overbought level AND the shorter-lookback moving average of close is less than or equal to the longer-lookback moving average of close
Exit: long, RSI crosses above the RSI mean exit level
Exit: short, RSI crosses below the RSI mean exit level