Calculation: Center = session VWAP or EMA, according to the configured center setting
Calculation: Upper strike = round upward to the configured strike increment of Center + ATR × configured multiplier
Calculation: Lower strike = round downward to the configured strike increment of Center − ATR × configured multiplier
Calculation: Strike width percentage = (Upper strike − Lower strike) / close × 100
Calculation: Upper stop = Upper strike + (Upper strike − Center) × (configured stop multiplier − 1)
Calculation: Lower stop = Lower strike − (Center − Lower strike) × (configured stop multiplier − 1)
Long: Current weekday is enabled for entry AND current time is within the configured entry window AND no trade is active AND no entry has been taken this week AND strike width percentage ≥ configured minimum width AND (SuperTrend filter is disabled OR neither bullish nor bearish OR strike width percentage ≥ configured trend width threshold) AND (RSI filter is disabled OR RSI is between its configured oversold and overbought thresholds, inclusive)
Short: Current weekday is enabled for entry AND current time is within the configured entry window AND no trade is active AND no entry has been taken this week AND strike width percentage ≥ configured minimum width AND (SuperTrend filter is disabled OR neither bullish nor bearish OR strike width percentage ≥ configured trend width threshold) AND (RSI filter is disabled OR RSI is between its configured oversold and overbought thresholds, inclusive)
Exit: Long, low ≤ Lower stop OR high ≥ Upper stop OR configured expiry-day exit window OR Friday safety exit window
Exit: Short, high ≥ Upper stop OR low ≤ Lower stop OR configured expiry-day exit window OR Friday safety exit window