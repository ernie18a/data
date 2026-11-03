Calculation: Heiken-Ashi weighted price = (HA high + HA low + 2 × HA close) / 4; HA close = (open + high + low + close) / 4; HA open = prior (HA open + HA close) / 2, initialized to open + close; HA high = max(high, HA open, HA close); HA low = min(low, HA open, HA close).
Calculation: Typical price = (high + low + close) / 3.
Calculation: TEMA(price, lookback) = EMA3 + 3 × (EMA1 − EMA2), where EMA1 is the exponential moving average of price, EMA2 is the exponential moving average of EMA1, and EMA3 is the exponential moving average of EMA2, all with the same lookback; initialize each EMA to its first input.
Calculation: Long line = 2 × TEMA(Heiken-Ashi weighted price, long lookback) − TEMA(TEMA(Heiken-Ashi weighted price, long lookback), same lookback); calculate on the chart timeframe or a higher timeframe, using the bar still forming.
Calculation: Short line = 2 × TEMA(typical price, short lookback) − TEMA(TEMA(typical price, short lookback), same lookback); calculate on the chart timeframe or a higher timeframe, using the bar still forming.
Long: Long line < Short line
Short: Long line > Short line