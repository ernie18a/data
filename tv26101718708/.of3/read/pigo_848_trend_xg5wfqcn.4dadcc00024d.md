Calculation: Band-break distance = DEMA(hlc3, impulse lookback) - RMA(high, impulse lookback) if DEMA(hlc3, impulse lookback) > RMA(high, impulse lookback); DEMA(hlc3, impulse lookback) - RMA(low, impulse lookback) if DEMA(hlc3, impulse lookback) < RMA(low, impulse lookback); 0 otherwise
Calculation: Band-break test = (Band-break distance - SMA(Band-break distance, impulse strength) != 0) AND (Band-break distance[1] - SMA(Band-break distance, impulse strength)[1] != 0)
Calculation: Trend state = up if (impulse-filter switch is off OR Band-break test) AND ((single-EMA approach AND EMA(close, shorter lookback) > EMA(close, shorter lookback)[1]) OR (two-EMA approach AND EMA(close, shorter lookback) > EMA(close, longer lookback))); down if (impulse-filter switch is off OR Band-break test) AND ((single-EMA approach AND EMA(close, shorter lookback) < EMA(close, shorter lookback)[1]) OR (two-EMA approach AND EMA(close, shorter lookback) < EMA(close, longer lookback))); neutral otherwise
Long: Trend state == up
Short: Trend state == down
Exit: long, Trend state == neutral
Exit: short, Trend state == neutral