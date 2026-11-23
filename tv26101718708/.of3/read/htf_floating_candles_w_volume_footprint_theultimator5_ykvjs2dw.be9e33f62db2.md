Long: T1 close >= T1 open, for each selected T1 candle; the current candle is still forming and prior candles are completed
Short: T1 close < T1 open, for each selected T1 candle; the current candle is still forming and prior candles are completed
Calculation: Net footprint delta = sum of footprint buy volume minus footprint sell volume over chart bars composing the selected number of latest T1 candles, including bars in the current forming T1 candle
Long: Net footprint delta >= 0 AND highest T1 high over the selected candles > lowest T1 low over the selected candles
Short: Net footprint delta < 0 AND highest T1 high over the selected candles > lowest T1 low over the selected candles