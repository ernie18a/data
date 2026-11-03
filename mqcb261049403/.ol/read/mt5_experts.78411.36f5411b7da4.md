Calculation: Fast EMA = exponential moving average of index closes on the configured auto-trade timeframe, using completed bars; its lookback is shorter than the slow EMA lookback. The configured timeframe may be higher or lower than the chart timeframe.
Calculation: Slow EMA = exponential moving average of index closes on the configured auto-trade timeframe, using completed bars; its lookback is longer than the fast EMA lookback.
Long: Fast EMA > Slow EMA
Short: Fast EMA < Slow EMA
Exit: long, Fast EMA < Slow EMA OR index price >= entry price + take-profit distance OR index price <= entry price - stop-loss distance
Exit: short, Fast EMA > Slow EMA OR index price <= entry price - take-profit distance OR index price >= entry price + stop-loss distance