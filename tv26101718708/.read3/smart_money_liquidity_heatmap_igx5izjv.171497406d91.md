Long: close > open AND close - open > ATR(lookback) * impulse multiplier
Short: close < open AND open - close > ATR(lookback) * impulse multiplier
Long: a new confirmed PivotHigh(high, pivot lookback, same pivot lookback) > the previous confirmed PivotHigh(high, pivot lookback, same pivot lookback)
Short: a new confirmed PivotLow(low, pivot lookback, same pivot lookback) < the previous confirmed PivotLow(low, pivot lookback, same pivot lookback)
Long: low > high[gap separation lookback] AND low - high[gap separation lookback] >= close * (minimum gap percentage / 100)
Short: high < low[gap separation lookback] AND low[gap separation lookback] - high >= close * (minimum gap percentage / 100)