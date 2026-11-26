Calculation: T1 EMA position = +1 when the current forming T1 close and EMA(close, EMA lookback) on T1 bars, read on chart bars, satisfy close > EMA; otherwise -1.
Calculation: T2 EMA position = +1 when the current forming T2 close and EMA(close, EMA lookback) on T2 bars, read on chart bars, satisfy close > EMA; otherwise -1.
Calculation: T1 structure position = +1 when the current forming T1 high and low are each above the previous completed T1 high and low, and at least two of the current and two previous completed T1 bars have close > open; -1 when the current forming T1 high and low are each below the previous completed T1 high and low, and fewer than two of those three bars have close > open; otherwise 0. Read T1 values on chart bars.
Calculation: T1 BB midpoint position = +1 when the current forming T1 close, read on chart bars, is above SMA(close, BB lookback) calculated on T1 bars; otherwise -1.
Calculation: Overall bias score = T1 EMA position + T2 EMA position + T1 structure position + T1 BB midpoint position.
Calculation: Chart EMA position = +1 when close > EMA(close, EMA lookback) on chart bars; otherwise -1.
Calculation: Chart structure position = +1 when the highest high and lowest low of the most recent structure-lookback chart bars are each above those of the preceding structure-lookback chart bars; -1 when each is below; otherwise 0.
Long: T1 EMA position = +1
Short: T1 EMA position = -1
Long: EMA(close, EMA lookback) on T1 bars, current forming value read on chart bars, > its value on the previous completed T1 bar
Short: EMA(close, EMA lookback) on T1 bars, current forming value read on chart bars, < its value on the previous completed T1 bar
Long: T2 EMA position = +1
Short: T2 EMA position = -1
Long: EMA(close, EMA lookback) on T2 bars, current forming value read on chart bars, > its value on the previous completed T2 bar
Short: EMA(close, EMA lookback) on T2 bars, current forming value read on chart bars, < its value on the previous completed T2 bar
Long: T1 structure position = +1
Short: T1 structure position = -1
Long: Bollinger %B(close, BB lookback, BB standard-deviation multiplier) on T1 bars, using the current forming T1 bar and read on chart bars, > 50; use 50 when the bands have zero width
Short: Bollinger %B(close, BB lookback, BB standard-deviation multiplier) on T1 bars, using the current forming T1 bar and read on chart bars, <= 50; use 50 when the bands have zero width
Long: Overall bias score >= 2
Short: Overall bias score <= -2
Long: Chart EMA position = +1
Short: Chart EMA position = -1
Long: Chart EMA position = +1 AND EMA(close, EMA lookback) on chart bars > its value on the previous chart bar AND Chart structure position = +1
Short: Chart EMA position = -1 AND EMA(close, EMA lookback) on chart bars < its value on the previous chart bar AND Chart structure position = -1
Long: Chart structure position = +1
Short: Chart structure position = -1