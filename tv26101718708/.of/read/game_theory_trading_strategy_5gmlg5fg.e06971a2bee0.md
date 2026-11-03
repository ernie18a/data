Calculation: Price momentum = close minus close a fixed lookback ago; smooth it with an SMA whose lookback is longer than the momentum lookback.
Calculation: Money flow = cumulative sum of volume × ((close − low) − (high − close)) / (high − low).
Calculation: Volume-weighted candle body = volume × (close − open) / (high − low); smooth it with an SMA using the same lookback as the price-momentum SMA.
Calculation: Equilibrium bands = SMA of close over the equilibrium lookback ± a deviation multiplier × standard deviation of close over the same lookback.
Long: low < lowest low over the liquidity lookback ending at the previous bar AND close > lowest low over the same bars AND volume > volume SMA × herd volume multiplier
Short: high > highest high over the liquidity lookback ending at the previous bar AND close < highest high over the same bars AND volume > volume SMA × herd volume multiplier
Long: RSI < lower RSI threshold AND volume > volume SMA × herd volume multiplier AND price momentum < its SMA AND money flow > its SMA AND volume > volume SMA × institutional volume multiplier
Short: RSI > upper RSI threshold AND volume > volume SMA × herd volume multiplier AND price momentum > its SMA AND money flow < its SMA AND volume > volume SMA × institutional volume multiplier
Long: close < lower equilibrium band AND volume-weighted candle body > its SMA AND NOT (RSI > upper RSI threshold AND volume > volume SMA × herd volume multiplier AND price momentum > its SMA)
Short: close > upper equilibrium band AND volume-weighted candle body <= its SMA AND NOT (RSI < lower RSI threshold AND volume > volume SMA × herd volume multiplier AND price momentum < its SMA)
Long: close < lower equilibrium band AND close > previous close AND volume > volume SMA
Short: close > upper equilibrium band AND close < previous close AND volume > volume SMA
Exit: long, low <= entry signal bar close × (1 − stop-loss fraction) OR high >= entry signal bar close × (1 + take-profit fraction)
Exit: short, high >= entry signal bar close × (1 + stop-loss fraction) OR low <= entry signal bar close × (1 − take-profit fraction)