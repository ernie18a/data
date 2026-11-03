Calculation: SSL trend state = 1 when close > the long-lookback SMA of high; -1 when close < the same-lookback SMA of low; otherwise retain the prior state.
Calculation: Smoothed candle open = EMA of (prior bar open + prior bar close) / 2.
Calculation: Smoothed candle high = EMA of max(high, close).
Calculation: Bar midpoint = (high + low) / 2.
Long: SSL trend state = 1 AND prior bar SSL trend state = -1 AND smoothed candle open > its prior-bar value AND EMA(close) < bar midpoint AND smoothed candle high < bar midpoint AND flat
Exit: long, high >= entry price × (1 + take-profit percentage / 100) OR (close < EMA(close) AND (stop percentage is disabled OR low <= entry price × (1 - stop-loss percentage / 100)))