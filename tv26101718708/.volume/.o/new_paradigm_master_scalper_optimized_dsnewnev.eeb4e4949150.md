Calculation: expected-move distance = twice the selected asset class’s base volatility multiplied by the global volatility multiplier
Calculation: lower band = VWAP − expected-move distance
Calculation: upper band = VWAP + expected-move distance
Long: low <= lower band adjusted by a proximity factor AND close > open AND volume > its short-lookback average multiplied by a configurable spike factor AND close > long-term EMA AND bar time is within the configured New York session
Short: high >= upper band adjusted by a proximity factor AND close < open AND volume > its short-lookback average multiplied by a configurable spike factor AND close < long-term EMA AND bar time is within the configured New York session
Exit: long, high >= entry price + configured profit distance OR low <= entry price − configured stop distance
Exit: short, low <= entry price − configured profit distance OR high >= entry price + configured stop distance