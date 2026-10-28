Calculation: Smart flow = EMA(((close − previous close) × volume) / SMA(volume, volume baseline lookback), smoothing lookback)
Calculation: Retail flow = EMA(−((close − previous close) × volume) / SMA(volume, same volume baseline lookback), same smoothing lookback)
Long: RSI(Smart flow, momentum lookback) crosses above 30
Short: RSI(Retail flow, same momentum lookback) crosses above 70