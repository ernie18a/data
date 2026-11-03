Calculation: Conversion line = midpoint of the highest high and lowest low over a short lookback on chart-timeframe bars
Calculation: Base line = midpoint of the highest high and lowest low over a longer lookback than the conversion line, on chart-timeframe bars
Calculation: Leading Span A = average of the conversion line and base line
Calculation: Leading Span B = midpoint of the highest high and lowest low over a longer lookback than the base line, on chart-timeframe bars
Calculation: Higher-timeframe SMA = simple moving average of close over higher-timeframe bars, using the last completed higher-timeframe bar
Long: Position is flat AND close > max(Leading Span A, Leading Span B) AND Leading Span A > Leading Span B AND close > Higher-timeframe SMA AND volume > its chart-timeframe simple moving average × a multiplier
Exit: Long, close < min(Leading Span A, Leading Span B)