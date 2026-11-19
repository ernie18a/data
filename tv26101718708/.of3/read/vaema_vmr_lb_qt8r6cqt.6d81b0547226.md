Calculation: V-AEMA core = EMA(source, EMA lookback) * EMA weight + (EMA(source, EMA lookback) + (if StDev(source, volatility lookback) > 0 then (source - EMA(source, EMA lookback)) / StDev(source, volatility lookback) * ATR(high, low, close, ATR lookback) * volatility drift scale else 0) * (1 - EMA weight)
Calculation: Volume ratio = if SMA(volume, volume lookback) > 0 then clamp(volume / SMA(volume, volume lookback), volume-ratio floor, volume-ratio cap) else fallback volume ratio
Calculation: Base width = StDev(source, volatility lookback) * standard-deviation width weight + ATR(high, low, close, ATR lookback) * ATR width weight
Calculation: Upper Band 1 = V-AEMA core + max(Base width * (upper base deviation + (Volume ratio - volume-ratio reference) * upper volume impact), minimum tick size * minimum tick count)
Calculation: Lower Band 1 = V-AEMA core - max(Base width * (lower base deviation + (Volume ratio - volume-ratio reference) * lower volume impact), minimum tick size * minimum tick count)
Calculation: Upper Band 2 = V-AEMA core + (Upper Band 1 - V-AEMA core) * upper extreme-band factor
Calculation: Lower Band 2 = V-AEMA core - (V-AEMA core - Lower Band 1) * lower extreme-band factor
Long: V-AEMA core >= V-AEMA core[1]
Short: V-AEMA core < V-AEMA core[1]
Long: source crosses above Upper Band 1 AND V-AEMA core > V-AEMA core[1]
Short: source crosses below Lower Band 1 AND V-AEMA core < V-AEMA core[1]
Long: close > Upper Band 2 AND low > Upper Band 1 AND NOT (close[1] > Upper Band 2[1] AND low[1] > Upper Band 1[1])
Short: close < Lower Band 2 AND high < Lower Band 1 AND NOT (close[1] < Lower Band 2[1] AND high[1] < Lower Band 1[1])