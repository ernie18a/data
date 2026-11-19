Calculation: Bullish BOS = current confirmed PivotHigh(high, structure lookback, structure lookback) > preceding confirmed PivotHigh
Calculation: Bearish BOS = current confirmed PivotLow(low, structure lookback, structure lookback) < preceding confirmed PivotLow
Long: Bullish BOS
Short: Bearish BOS
Long: Bullish BOS AND the preceding consecutive BOS direction was bearish
Short: Bearish BOS AND the preceding consecutive BOS direction was bullish
Long: PivotLow(low, order-block lookback, order-block lookback) is confirmed
Short: PivotHigh(high, order-block lookback, order-block lookback) is confirmed
Long: low > high[2] AND (low - high[2]) / close * 100 >= minimum gap percentage
Short: low[2] > high AND (low[2] - high) / close * 100 >= minimum gap percentage
Long: low[1] < lowest(low, sweep lookback)[1] AND close > lowest(low, sweep lookback)[1] AND close[1] < lowest(low, sweep lookback)[1]
Short: high[1] > highest(high, sweep lookback)[1] AND close < highest(high, sweep lookback)[1] AND close[1] > highest(high, sweep lookback)[1]