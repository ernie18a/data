Calculation: Smoothed DI spread = 2 × (DI+(base DI lookback) − DI−(base DI lookback)) + (base first smoothing factor − 2) × (DI+(base DI lookback)[1] − DI−(base DI lookback)[1]) + (1 − base first smoothing factor) × Smoothed DI spread[1]
Calculation: DI cloud score = base second smoothing factor × Smoothed DI spread + (1 − base second smoothing factor) × DI cloud score[1]
Long: DI cloud score > 0
Short: DI cloud score < 0
Calculation: Smoothed DI spread on T1 bars = 2 × (DI+(T1, T1 DI lookback) − DI−(T1, T1 DI lookback)) + (T1 first smoothing factor − 2) × (DI+(T1, T1 DI lookback)[1] − DI−(T1, T1 DI lookback)[1]) + (1 − T1 first smoothing factor) × Smoothed DI spread on T1 bars[1]
Calculation: DI cloud score on T1 bars = T1 second smoothing factor × Smoothed DI spread on T1 bars + (1 − T1 second smoothing factor) × DI cloud score on T1 bars[1]
Long: DI cloud score from T1's current forming bar > 0, sampled on chart bars
Short: DI cloud score from T1's current forming bar < 0, sampled on chart bars