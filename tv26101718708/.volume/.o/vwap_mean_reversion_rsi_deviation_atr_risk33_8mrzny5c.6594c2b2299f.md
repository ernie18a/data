Calculation: VWAP deviation score = (close − VWAP − SMA(close − VWAP, lookback)) / standard deviation(close − VWAP, lookback); if the standard deviation is zero, use 0
Calculation: Higher-timeframe EMA = EMA of higher-timeframe close, using the last completed higher-timeframe bar
Calculation: ATR risk distance = ATR × configured stop multiple
Calculation: Long stop = entry price − ATR risk distance; long fixed-R target = entry price + ATR risk distance × configured target multiple
Calculation: Short stop = entry price + ATR risk distance; short fixed-R target = entry price − ATR risk distance × configured target multiple
Calculation: Long limit = if VWAP targeting is enabled, max(VWAP, long fixed-R target); otherwise long fixed-R target
Calculation: Short limit = if VWAP targeting is enabled, min(VWAP, short fixed-R target); otherwise short fixed-R target
Long: within configured session if the session filter is enabled AND close ≥ higher-timeframe EMA if the trend filter is enabled AND VWAP deviation score ≤ −configured deviation threshold AND RSI ≤ configured oversold threshold
Short: within configured session if the session filter is enabled AND close ≤ higher-timeframe EMA if the trend filter is enabled AND VWAP deviation score ≥ configured deviation threshold AND RSI ≥ configured overbought threshold
Exit: long, low ≤ long stop OR high ≥ long limit OR time in position ≥ configured bar limit if the time stop is enabled
Exit: short, high ≥ short stop OR low ≤ short limit OR time in position ≥ configured bar limit if the time stop is enabled