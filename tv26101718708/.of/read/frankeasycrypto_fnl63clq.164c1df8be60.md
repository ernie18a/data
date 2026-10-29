Calculation: Wick-adjusted high = high if wick use is enabled, otherwise close
Calculation: Wick-adjusted low = low if wick use is enabled, otherwise close
Calculation: Supertrend long stop = source − multiplier × ATR; when positive, hold the previous stop on a doji, otherwise use the greater of this value and the previous stop if the previous wick-adjusted low is above the previous stop; when nonpositive, use the previous stop
Calculation: Supertrend short stop = source + multiplier × ATR; when positive, hold the previous stop on a doji, otherwise use the lesser of this value and the previous stop if the previous wick-adjusted high is below the previous stop; when nonpositive, use the previous stop
Calculation: Supertrend direction = starts long; switches short when long and wick-adjusted low < previous long stop; switches long when short and wick-adjusted high > previous short stop; otherwise unchanged
Calculation: Short EMA = EMA of configured source with a shorter lookback than the long EMA
Calculation: Long EMA = EMA of configured source with a longer lookback than the short EMA
Calculation: Trend SMA = SMA of configured source; use chart-timeframe bars when selected, otherwise use bars from the selected alternate timeframe, which may be higher or lower than the chart timeframe, including its still-forming bar
Calculation: ATR channel = trend SMA ± ATR × configured channel-width parameter, using an ATR lookback equal to the trend SMA lookback
Calculation: Filtered trend = neutral if (open ≤ channel top OR close ≤ channel top) AND (open ≥ channel bottom OR close ≥ channel bottom); otherwise bullish if configured source ≥ trend SMA, else bearish
Calculation: EMA signal state = long if prior state ≠ long and filtered trend is bullish and short EMA > long EMA; else short if prior state ≠ short and filtered trend is bearish and short EMA < long EMA; else neutral if prior state ≠ neutral and ((filtered trend is bullish and short EMA < long EMA) OR (filtered trend is bearish and short EMA > long EMA)); else prior state
Long: Supertrend direction = long AND prior Supertrend direction = short OR EMA signal state = long AND prior EMA signal state ≠ long OR long EMA crosses above trend SMA
Short: Supertrend direction = short AND prior Supertrend direction = long OR EMA signal state = short AND prior EMA signal state ≠ short OR long EMA crosses below trend SMA
Exit: long, prior EMA signal state ≠ neutral AND filtered trend is bullish AND short EMA < long EMA
Exit: short, prior EMA signal state ≠ neutral AND filtered trend is bearish AND short EMA > long EMA