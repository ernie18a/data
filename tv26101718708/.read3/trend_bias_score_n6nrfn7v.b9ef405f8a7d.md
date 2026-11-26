Calculation: Candle(T) = (close >= open ? 1 : -1), on T bars, forming bar
Calculation: DeltaVolume(T) = volume * Candle(T), on T bars, forming bar
Calculation: Trend(T, a, b, c) = trendW1*(close > MA(close, a, maType) ? 1 : -1) + trendW2*(MA(close, a, maType) > MA(close, b, maType) ? 1 : -1) + trendW3*(MA(close, b, maType) > MA(close, c, maType) ? 1 : -1), with a < b < c, on T bars, forming bar
Calculation: Momentum(T) = (RSI(close, rsiLen) - 50) / 50, on T bars, forming bar
Calculation: Accel(T) = (MACDHist(close, macdFast, macdSlow, macdSignal) - MACDHist(close, macdFast, macdSlow, macdSignal)[1] > 0 ? 1 : -1), on T bars, forming bar
Calculation: VolBias(T) = (DeltaVolume(T) > EMA(DeltaVolume(T), volLen) ? Candle(T) : 0), on T bars, forming bar
Calculation: ATRBias(T) = (ATR(atrLen) > EMA(ATR(atrLen), atrSmoothLen) ? 1 : -1), on T bars, forming bar
Calculation: OIBias(T) = Candle(T) * (close of open interest > SMA(close of open interest, oiLen) ? 1 : -oiFactor), on T bars, forming bar
Calculation: Energy(T) = (wVol*VolBias(T) + wAtr*ATRBias(T) + wOi*OIBias(T)) / (wVol + wAtr + wOi), with the OIBias term and wOi omitted when open interest is unavailable, on chart bars taking forming T values
Calculation: Bias(T, a, b, c) = (wTrend*Trend(T, a, b, c) + wMomentum*Momentum(T) + wAccel*Accel(T) + wEnergy*Energy(T)) / (wTrend + wMomentum + wAccel + wEnergy), on chart bars taking forming T values
Long: w1*Bias(T1, a1, b1, c1) + w2*Bias(T2, a2, b2, c2) + w3*Bias(T3, a3, b3, c3) + w4*Bias(T4, a4, b4, c4) + w5*Bias(T5, a5, b5, c5) + w6*Bias(T6, a6, b6, c6) > 0
Short: w1*Bias(T1, a1, b1, c1) + w2*Bias(T2, a2, b2, c2) + w3*Bias(T3, a3, b3, c3) + w4*Bias(T4, a4, b4, c4) + w5*Bias(T5, a5, b5, c5) + w6*Bias(T6, a6, b6, c6) < 0
Long: Bias(T7, a7, b7, c7) > 0
Long: Bias(T8, a8, b8, c8) > 0
Long: Bias(T9, a9, b9, c9) > 0
Long: Bias(T10, a10, b10, c10) > 0
Long: Bias(T11, a11, b11, c11) > 0
Long: Bias(T12, a12, b12, c12) > 0
Short: Bias(T7, a7, b7, c7) < 0
Short: Bias(T8, a8, b8, c8) < 0
Short: Bias(T9, a9, b9, c9) < 0
Short: Bias(T10, a10, b10, c10) < 0
Short: Bias(T11, a11, b11, c11) < 0
Short: Bias(T12, a12, b12, c12) < 0