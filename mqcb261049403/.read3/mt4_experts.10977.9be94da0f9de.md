Calculation: moving average = SMA((high+low+close)/3, MA lookback, T1 forming bar sampled on chart bars)
Calculation: volatility = ATR(high, low, close, ATR lookback, T2 forming bar sampled on chart bars)
Calculation: entry gate = initially open; after an entry, closed until highest high since that entry > entry price + noise distance OR lowest low since that entry < entry price - noise distance, then open until the next entry
Long: close <= moving average AND moving average - close < MA proximity distance AND volatility < ATR ceiling AND entry gate is open
Short: close > moving average AND close - moving average < MA proximity distance AND volatility < ATR ceiling AND entry gate is open
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance