Calculation: Rounded trend line = Jurik moving average of the FATL digital filter applied to a selected OHLC-derived price, rounded to a configurable price increment. Calculate on the chart timeframe or a configurable higher or lower timeframe; for another timeframe use the last completed bar, or the still-forming bar if configured.
Calculation: Trend direction = sign of the rounded trend line's change from the preceding bar; when the change is zero, retain the preceding direction.
Long: trend direction > 0
Short: trend direction < 0
Exit: long, trend direction < 0 OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, trend direction > 0 OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance