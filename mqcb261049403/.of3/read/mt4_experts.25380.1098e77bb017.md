Calculation: LWMA spread = LWMA(typical price, shorter lookback, T2, bar still forming, sampled on chart bars) - LWMA(typical price, longer lookback, T2, bar still forming, sampled on chart bars)
Calculation: Entry distance = entry-distance parameter in points × point size
Calculation: Chart MACD = MACD(close, fast lookback, slow lookback, signal lookback, chart timeframe, last completed bar)
Calculation: T1 MACD = MACD(close, fast lookback, slow lookback, signal lookback, T1, last completed bar, sampled on chart bars)
Calculation: T2 MACD = MACD(close, fast lookback, slow lookback, signal lookback, T2, last completed bar, sampled on chart bars)
Long: LWMA spread < 0 AND low[2] < high[1] AND Chart MACD.main != 0 AND Chart MACD.main > Chart MACD.signal AND T1 MACD.main != 0 AND T1 MACD.main > T1 MACD.signal AND T2 MACD.main != 0 AND T2 MACD.main > T2 MACD.signal AND abs(close[0] - close[2]) > Entry distance
Short: LWMA spread < 0 AND low[1] < high[2] AND Chart MACD.main != 0 AND Chart MACD.main < Chart MACD.signal AND T1 MACD.main != 0 AND T1 MACD.main < T1 MACD.signal AND T2 MACD.main != 0 AND T2 MACD.main < T2 MACD.signal AND abs(close[0] - close[1]) > Entry distance