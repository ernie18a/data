Calculation: Long-bodied candle = abs(close - open) / (high - low) > body-ratio parameter
Long: abs(close - open) <= doji-size parameter * (high - low) AND datetime is within the configured date range AND (volume filter is disabled OR volume > EMA(volume, volume lookback)); place a buy stop at high if Long-bodied candle[1] AND (high - low)[1] > high - low, otherwise at max(high, high[1])
Short: abs(close - open) <= doji-size parameter * (high - low) AND datetime is within the configured date range AND (volume filter is disabled OR volume > EMA(volume, volume lookback)); place a sell stop at low if Long-bodied candle[1] AND (high - low)[1] > high - low, otherwise at min(low, low[1])
Exit: long, true
Exit: short, true