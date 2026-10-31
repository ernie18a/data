Calculation: Rounded double-smoothed average = round a moving average of a moving average of the selected OHLC-derived price to the nearest configurable price increment; the two smoothing methods and lookbacks are independently configurable, with the first lookback longer than the second.
Calculation: Direction = sign of the change in the rounded double-smoothed average from the previous bar; if the change is zero, retain the previous direction.
Long: Chart-timeframe direction > 0
Short: Chart-timeframe direction < 0
Long: Direction on the last completed higher-timeframe bar > 0 AND direction on the preceding higher-timeframe bar < 0
Short: Direction on the last completed higher-timeframe bar < 0 AND direction on the preceding higher-timeframe bar > 0
Exit: long, direction on the last completed higher-timeframe bar < 0 OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance
Exit: short, direction on the last completed higher-timeframe bar > 0 OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance