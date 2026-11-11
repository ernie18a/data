Calculation: EMA 0 is the close EMA on the chart timeframe; EMA 1 through EMA 4 use the same EMA length on four successively higher timeframes. With lookahead off, historical bars use the latest completed higher-timeframe bar; realtime bars use the higher-timeframe bar still forming.
Long: EMA 1 > EMA 0 AND EMA 2 > EMA 1 AND EMA 3 > EMA 2 AND EMA 4 > EMA 3
Short: EMA 1 < EMA 0 AND EMA 2 < EMA 1 AND EMA 3 < EMA 2 AND EMA 4 < EMA 3
Long: position is flat AND EMA 0 - close >= minimum entry distance AND EMA 0 - close <= maximum entry distance AND EMA 1 > EMA 0 AND EMA 2 > EMA 1 AND EMA 3 > EMA 2 AND EMA 4 > EMA 3
Short: position is flat AND close - EMA 0 >= minimum entry distance AND close - EMA 0 <= maximum entry distance AND EMA 1 < EMA 0 AND EMA 2 < EMA 1 AND EMA 3 < EMA 2 AND EMA 4 < EMA 3
Exit: long, close > EMA 4 AND previous close <= previous EMA 4
Exit: short, close < EMA 4 AND previous close >= previous EMA 4