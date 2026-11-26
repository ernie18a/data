Calculation: EMA slope = EMA(close, mirror lookback) − EMA(close, mirror lookback)[1]
Calculation: dynamic width = ATR(ATR lookback) × (1 + abs(EMA slope) / ATR(ATR lookback) × trend expansion coefficient) / (1 + ATR(ATR lookback) / SMA(ATR(ATR lookback), ATR-average lookback) × squeeze compression coefficient)
Calculation: projected centerline = EMA(close, mirror lookback) + EMA slope × (1 + (SMA(close > close[1] ? volume : close < close[1] ? −volume : 0, directional-volume lookback) > 0 ? directional-volume influence : −directional-volume influence) × projection length
Calculation: projection position = if dynamic width > 0 then clamp((close − (projected centerline − dynamic width)) / (2 × dynamic width), unit interval) else midpoint of unit interval
Long: projection position <= lower-zone threshold
Short: projection position > upper-zone threshold