Calculation: Top anchored VWAP = Anchored VWAP(close, volume, top anchor time)
Calculation: Bottom anchored VWAP = Anchored VWAP(close, volume, bottom anchor time)
Long: time >= bottom anchor time AND low <= Bottom anchored VWAP AND close > Bottom anchored VWAP AND close > Bottom anchored VWAP[1]
Short: time >= top anchor time AND high >= Top anchored VWAP AND close < Top anchored VWAP AND close < Top anchored VWAP[1]