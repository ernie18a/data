Calculation: Channel reference = rolling lowest of the specified timeframe’s open over a lookback if close > rolling highest of that open; otherwise rolling highest. Use the specified timeframe’s current, still-forming bar open; it may be higher or lower than the chart timeframe.
Long: close > channel reference AND previous close <= previous channel reference
Short: close < channel reference AND previous close >= previous channel reference
Exit: long, close crosses below channel reference OR high >= channel reference × (1 + each configured take-profit percentage)
Exit: short, close crosses above channel reference OR low <= channel reference × (1 − each configured take-profit percentage)