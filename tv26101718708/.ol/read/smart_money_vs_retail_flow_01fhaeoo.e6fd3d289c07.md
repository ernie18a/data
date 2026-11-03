Calculation: Smart-money flow = EMA(((close - previous close) × volume) / SMA(volume, lookback), smoothing period)
Calculation: Retail flow = EMA(-((close - previous close) × volume) / SMA(volume, lookback), smoothing period)
Long: RSI(Smart-money flow, lookback) crosses above 30
Short: RSI(Retail flow, lookback) crosses above 70