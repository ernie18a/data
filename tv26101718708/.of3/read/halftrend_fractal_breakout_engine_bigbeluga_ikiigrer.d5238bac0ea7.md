Calculation: UpperBand = HalfTrend(high, low, close, amplitude) + ATR(high, low, close, ATR lookback) * channel deviation
Calculation: LowerBand = HalfTrend(high, low, close, amplitude) - ATR(high, low, close, ATR lookback) * channel deviation
Calculation: TrendUp = true if close crosses above UpperBand, false if close crosses below LowerBand, else previous TrendUp
Calculation: PendingTopLevel = none if TrendUp changes or (bar is closed AND TrendUp AND PendingTopLevel exists AND close > PendingTopLevel), else high[2] if WilliamsTopFractal(high) AND TrendUp, else previous PendingTopLevel
Calculation: PendingBottomLevel = none if TrendUp changes or (bar is closed AND NOT TrendUp AND PendingBottomLevel exists AND close < PendingBottomLevel), else low[2] if WilliamsBottomFractal(low) AND NOT TrendUp, else previous PendingBottomLevel
Long: close crosses above UpperBand
Short: close crosses below LowerBand
Long: TrendUp AND bar is closed AND PendingTopLevel exists AND close > PendingTopLevel
Short: NOT TrendUp AND bar is closed AND PendingBottomLevel exists AND close < PendingBottomLevel