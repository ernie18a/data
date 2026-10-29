Calculation: VWRSI = let G = RMA(max(close − prior close, 0) × volume, lookback) / RMA(volume, lookback), L = RMA(max(prior close − close, 0) × volume, lookback); VWRSI = 100 if L = 0, otherwise 0 if G = 0, otherwise 100 − 100 / (1 + G / L)
Long: prior VWRSI ≤ oversold threshold AND VWRSI > oversold threshold OR prior VWRSI ≤ its EMA AND VWRSI > its EMA
Short: prior VWRSI ≥ overbought threshold AND VWRSI < overbought threshold OR prior VWRSI ≥ its EMA AND VWRSI < its EMA
Exit: long, prior VWRSI ≥ its EMA AND VWRSI < its EMA
Exit: short, prior VWRSI ≤ its EMA AND VWRSI > its EMA