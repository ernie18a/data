Calculation: Mid moving average = selected HMA, EMA, or SMA(source, mid lookback)
Calculation: Adaptive band width = standard-deviation weight × StDev(source, standard-deviation lookback) + ATR weight × ATR(ATR lookback) + VWMA-deviation weight × ABS(VWMA(source, VWMA lookback) − SMA(source, VWMA lookback))
Calculation: Upper band = Mid moving average + Adaptive band width
Calculation: Lower band = Mid moving average − Adaptive band width
Long: close >= Mid moving average
Long: close > Upper band AND volume > SMA(volume, VWMA lookback) × volume multiplier AND (momentum confirmation disabled OR RSI(source, RSI lookback) > RSI threshold) AND on chart bars, current (still-forming) T1 close > current (still-forming) T1 selected HMA, EMA, or SMA(source, mid lookback)
Short: close < Mid moving average
Short: close < Lower band AND volume > SMA(volume, VWMA lookback) × volume multiplier AND (momentum confirmation disabled OR RSI(source, RSI lookback) < RSI threshold) AND on chart bars, current (still-forming) T1 close < current (still-forming) T1 selected HMA, EMA, or SMA(source, mid lookback)