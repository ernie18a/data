Calculation: retained pivot = confirmed PivotHigh(high, left pivot lookback, right pivot lookback) or PivotLow(low, left pivot lookback, right pivot lookback); when the preceding pivot direction is high, discard a lower high and a low above the latest retained pivot; when it is low, discard a higher low and a high below the latest retained pivot.
Calculation: swing values = p0, the current retained pivot, and p1 through p4, the latest retained pivots of alternating types searched within the pivot-history lookback; missing values are 0.
Calculation: higher high = a current retained pivot exists AND p0 > p1 AND p0 > p2 AND p2 > p1 AND p2 > p3
Calculation: lower low = a current retained pivot exists AND p0 < p1 AND p0 < p2 AND p2 < p1 AND p2 < p3
Calculation: higher low = a current retained pivot exists AND ((p0 >= p2 AND p1 > p2 AND p1 > p3 AND p3 > p2 AND p3 > p4) OR (p0 < p1 AND p0 > p2 AND p1 < p3))
Calculation: lower high = a current retained pivot exists AND ((p0 <= p2 AND p1 < p2 AND p1 < p3 AND p3 < p2 AND p3 < p4) OR (p0 > p1 AND p0 < p2 AND p1 > p3))
Calculation: pre-update resistance = if lower high then p0 else prior resistance
Calculation: pre-update support = if higher low then p0 else prior support
Calculation: trend = if close > pre-update resistance then up, else if close < pre-update support then down, else prior trend (zero if undefined)
Calculation: resistance = if (trend is up AND higher high) OR (trend is down AND lower high) then p0 else pre-update resistance
Calculation: support = if (trend is up AND higher low) OR (trend is down AND lower low) then p0 else pre-update support
Calculation: open profit = trade amount × (close − entry price) for a long position or trade amount × (entry price − close) for a short position
Calculation: full-close trigger = EMA(shortest EMA lookback) crosses EMA(third-shortest EMA lookback) OR (prior side is short AND EMA(shortest EMA lookback) > EMA(second-shortest EMA lookback) AND open profit < minimum-profit parameter) OR (prior side is long AND EMA(shortest EMA lookback) < EMA(second-shortest EMA lookback) AND open profit < minimum-profit parameter)
Calculation: pending side = if prior side exists, flat when full-close trigger is true and otherwise the prior side; if prior side is absent, long when trend is up AND EMA(close, shortest through longest of seven strictly increasing lookbacks) are in strictly descending order AND Supertrend direction(factor, ATR lookback, T1 still-forming bar), mapped to chart bars, < 0; otherwise short when trend is not up AND those EMA values are in strictly ascending order AND that Supertrend direction > 0; otherwise flat
Long: higher high
Long: higher low
Short: lower low
Short: lower high
Long: pending side is long AND no position was active on the prior chart bar AND RSI(close, RSI lookback, T1 still-forming bar), mapped to chart bars, one chart bar ago > that RSI value two chart bars ago AND Supertrend(factor, ATR lookback) on the current chart bar differs from its value on the prior chart bar
Short: pending side is short AND no position was active on the prior chart bar AND RSI(close, RSI lookback, T1 still-forming bar), mapped to chart bars, one chart bar ago < that RSI value two chart bars ago AND Supertrend(factor, ATR lookback) on the current chart bar differs from its value on the prior chart bar
Exit: Long, full-close trigger
Exit: Short, full-close trigger