Calculation: normalized ATR = (ATR − lowest ATR over the ATR lookback) / (highest ATR over the ATR lookback − lowest ATR over the ATR lookback)
Calculation: dynamic overbought = min(100, base overbought + normalized ATR × (100 − base overbought) × ATR scaling)
Calculation: dynamic oversold = max(0, base oversold − normalized ATR × base oversold × ATR scaling)
Calculation: short-term MA = selected moving average of close using a shorter lookback
Calculation: long-term MA = selected moving average of close using a longer lookback
Long: RSI crosses below dynamic oversold AND (trend filter is off OR short-term MA ≥ long-term MA)
Short: RSI crosses above dynamic overbought AND (trend filter is off OR short-term MA ≤ long-term MA)
Exit: long, RSI crosses above the mean RSI level
Exit: short, RSI crosses below the mean RSI level