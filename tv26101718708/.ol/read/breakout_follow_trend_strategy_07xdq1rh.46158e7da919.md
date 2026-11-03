Long: close > upper Bollinger Band AND close > EMA AND volume > volume SMA AND hour is within the configured trading window AND realized daily P&L is above the configured daily loss limit AND bars since the last position close exceed the configured cooldown
Short: close < lower Bollinger Band AND close < EMA AND volume > volume SMA AND hour is within the configured trading window AND realized daily P&L is above the configured daily loss limit AND bars since the last position close exceed the configured cooldown
Calculation: ATR-based stop distance = ATR multiplied by a configurable stop-distance multiplier
Exit: Long, low <= entry price - ATR-based stop distance OR high >= entry price + ATR-based stop distance × configured full reward-risk ratio
Exit: Short, high >= entry price + ATR-based stop distance OR low <= entry price - ATR-based stop distance × configured full reward-risk ratio
Exit: Long, high >= entry price + ATR-based stop distance × configured partial reward-risk ratio
Exit: Short, low <= entry price - ATR-based stop distance × configured partial reward-risk ratio