Calculation: RSI slope = RSI minus RSI a configurable number of bars ago.
Calculation: Adaptive boost = min(8, 0.35 × standard deviation of RSI over the RSI lookback).
Calculation: Dynamic lower zone = max(10, base lower zone − adaptive boost).
Calculation: Dynamic extreme lower zone = max(5, extreme lower zone − 0.5 × adaptive boost).
Calculation: Dynamic upper zone = min(90, base upper zone + adaptive boost).
Calculation: Dynamic extreme upper zone = min(95, extreme upper zone + 0.5 × adaptive boost).
Long: Reversal signals enabled AND (RSI <= dynamic lower zone OR RSI <= dynamic extreme lower zone) AND RSI crosses above its EMA AND RSI slope > 0 AND RSI > previous RSI AND (trend filter disabled OR close > EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Short: Reversal signals enabled AND (RSI >= dynamic upper zone OR RSI >= dynamic extreme upper zone) AND RSI crosses below its EMA AND RSI slope < 0 AND RSI < previous RSI AND (trend filter disabled OR close < EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Long: Continuation signals enabled AND RSI > mid level AND RSI crosses above its EMA AND RSI slope > 0 AND RSI > its EMA AND (trend filter disabled OR close > EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Short: Continuation signals enabled AND RSI < mid level AND RSI crosses below its EMA AND RSI slope < 0 AND RSI < its EMA AND (trend filter disabled OR close < EMA of close) AND (volume filter disabled OR volume > SMA of volume × volume multiplier).
Exit: long, RSI > mid level AND RSI crosses below its EMA AND RSI slope < 0.
Exit: short, RSI < mid level AND RSI crosses above its EMA AND RSI slope > 0.