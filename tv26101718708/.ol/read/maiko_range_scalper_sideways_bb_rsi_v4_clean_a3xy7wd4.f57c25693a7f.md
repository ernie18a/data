Calculation: Higher-timeframe resistance = highest high over the longer-term lookback of higher-timeframe bars, using the last completed higher-timeframe bar
Calculation: Higher-timeframe support = lowest low over the longer-term lookback of higher-timeframe bars, using the last completed higher-timeframe bar
Calculation: Long stop = higher-timeframe support × (1 − stop buffer percentage)
Calculation: Short stop = higher-timeframe resistance × (1 + stop buffer percentage)
Calculation: Long target = Bollinger basis in mid-band mode, otherwise the greater of the Bollinger basis and higher-timeframe resistance
Calculation: Short target = Bollinger basis in mid-band mode, otherwise the lesser of the Bollinger basis and higher-timeframe support
Long: close is between higher-timeframe support and resistance inclusive AND (VWAP filter is disabled OR absolute(close − VWAP) / VWAP × 100 ≤ VWAP tolerance percentage) AND close ≤ lower Bollinger Band AND RSI ≤ long threshold
Short: close is between higher-timeframe support and resistance inclusive AND (VWAP filter is disabled OR absolute(close − VWAP) / VWAP × 100 ≤ VWAP tolerance percentage) AND close ≥ upper Bollinger Band AND RSI ≥ short threshold
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target