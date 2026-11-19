Calculation: Rope = close on the first bar; thereafter prior Rope + max(abs(close - prior Rope) - StDev(close - VWAP((high + low + close) / 3), lookback) * multiplier, 0) * sign(close - prior Rope), treating an unavailable threshold as zero
Long: crossover(close, Rope) OR (Rope > Rope[1] AND Rope[1] <= Rope[2])
Short: crossunder(close, Rope) OR (Rope <= Rope[1] AND Rope[1] > Rope[2])