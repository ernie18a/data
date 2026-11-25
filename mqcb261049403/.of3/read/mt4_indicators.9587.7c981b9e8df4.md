Calculation: Upper boundary = moving average(high, lookback, T1)
Calculation: Lower boundary = moving average(low, same lookback, T1)
Long: On chart bars, close(T1, last completed bar) < lower boundary(T1, last completed bar) AND close(T1, forming bar) > lower boundary(T1, forming bar) OR close(T1, last completed bar) < upper boundary(T1, last completed bar) AND close(T1, forming bar) > upper boundary(T1, forming bar)
Short: On chart bars, close(T1, last completed bar) > lower boundary(T1, last completed bar) AND close(T1, forming bar) < lower boundary(T1, forming bar) OR close(T1, last completed bar) > upper boundary(T1, last completed bar) AND close(T1, forming bar) < upper boundary(T1, forming bar)
Calculation: EMA slope angle = atan((EMA(close, lookback) - EMA(close, lookback)[1]) / (instrument tick value × instrument tick size × scale factor)) × 180/π, on chart bars using the forming and last completed bars
Long: EMA slope angle > upper angle threshold
Short: EMA slope angle < lower angle threshold