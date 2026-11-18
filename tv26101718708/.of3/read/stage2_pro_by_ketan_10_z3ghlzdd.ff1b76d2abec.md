Calculation: T1 stage = on chart bars, current (possibly forming) close(T1) > SMA(close, stage lookback, evaluated on T1 bars including the current bar) AND current (possibly forming) close(T1) > SMA(close, monthly-MA lookback, evaluated on T2 bars including the current bar)
Calculation: monthly RSI strength = on chart bars, RSI(close, RSI lookback, evaluated on T2 bars including the current possibly forming bar) > RSI threshold
Long: T1 stage
Long: on chart bars using current (possibly forming) T3 values, barssince(high >= highest(high[1], breakout lookback), evaluated and counted on T3 bars) <= hold lookback
Long: on chart bars using current (possibly forming) T3 values, close(T3) > EMA(close, structure lookback, evaluated on T3 bars including the current bar)
Long: monthly RSI strength
Long: T1 stage AND on chart bars using current (possibly forming) T2 values, close(T2) > SMA(close, monthly-MA lookback, evaluated on T2 bars including the current bar) AND monthly RSI strength
Calculation: scaled benchmark close = current (possibly forming) benchmark close(T1) * SMA(close(T1) values sampled on chart bars, shared normalization lookback) / SMA(benchmark close(T1) values sampled on chart bars, same shared normalization lookback)
Long: on chart bars using current (possibly forming) T1 values, benchmark close is available and positive AND scaled benchmark close is defined AND close(T1) > scaled benchmark close
Calculation: elevated daily volume = on T3 bars including the current possibly forming bar, volume > SMA(volume, volume-average lookback) * volume multiplier
Calculation: recent daily volume maximum = on T3 bars including the current possibly forming bar, volume >= highest(volume, recent-volume lookback)
Calculation: historical daily volume maximum = on T3 bars including the current possibly forming bar, volume >= highest(volume, maximum-history lookback)
Long: on chart bars using current (possibly forming) T3 values, close(T3) >= open(T3) AND (recent daily volume maximum OR elevated daily volume) AND NOT historical daily volume maximum
Short: on chart bars using current (possibly forming) T3 values, close(T3) < open(T3) AND (recent daily volume maximum OR elevated daily volume) AND NOT historical daily volume maximum