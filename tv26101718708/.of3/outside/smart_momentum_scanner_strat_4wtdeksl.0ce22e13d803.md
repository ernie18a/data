Calculation: established trend = close > EMA(close, trend EMA length) AND EMA(close, fast EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, slow EMA length) AND EMA(close, trend EMA length) > EMA(close, trend EMA length)[EMA slope lookback]
Calculation: volume confirmation = volume >= SMA(volume, average volume length) × volume confirmation multiplier
Calculation: VWAP confirmation = VWAP filter disabled OR close > VWAP anchored to T1
Calculation: market confirmation = market filter disabled OR market ETF close > EMA(market ETF close, reference ETF EMA length)
Calculation: sector confirmation = sector filter disabled OR sector ETF close > EMA(sector ETF close, reference ETF EMA length)
Calculation: bullish continuation setup = Pivot Low(low, left pivot bars, right pivot bars) followed by bullish reversal, a higher Pivot Low, and continuation
Long: bullish continuation setup AND volume confirmation AND VWAP confirmation AND market confirmation AND sector confirmation AND NOT established trend AND close > EMA(close, mid EMA length) AND EMA(close, fast EMA length) > EMA(close, mid EMA length) AND EMA(close, mid EMA length) > EMA(close, mid EMA length)[EMA slope lookback]
Long: bullish continuation setup AND volume confirmation AND VWAP confirmation AND market confirmation AND sector confirmation AND established trend