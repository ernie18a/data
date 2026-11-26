Calculation: BarDelta = volume * (2 * close - high - low) / (high - low), or 0 when high = low
Calculation: VolumeDelta = SUM(BarDelta, shorter delta lookback)
Calculation: CVD = CUM(BarDelta)
Calculation: CVDTrend = Rising if CVD > EMA(CVD, CVD smoothing length) AND CVD - CVD[CVD slope lookback] > 0; Falling if CVD < EMA(CVD, CVD smoothing length) AND CVD - CVD[CVD slope lookback] < 0; otherwise Flat
Calculation: EMATrend = Above if close > EMA(close, shorter EMA length) AND EMA(close, shorter EMA length) > EMA(close, longer EMA length); Below if close < EMA(close, shorter EMA length) AND EMA(close, shorter EMA length) < EMA(close, longer EMA length); otherwise Mixed
Calculation: StructureTrend = Up if the latest confirmed PivotHigh(high, pivot length, pivot length) is above the previous one AND the latest confirmed PivotLow(low, pivot length, pivot length) is above the previous one; Down if both are below the previous one; otherwise Range
Calculation: BullShare = (delta weight * DeltaScore + CVD weight * CVDScore + EMA weight * EMAScore + structure weight * StructureScore) / (delta weight + CVD weight + EMA weight + structure weight), where DeltaScore = 50 + delta score scale * VolumeDelta / SMA(ABS(VolumeDelta), longer delta average lookback) clamped to 0..100, or 50 when that SMA is 0; CVDScore = 100 if CVDTrend = Rising, 0 if CVDTrend = Falling, else 50; EMAScore = 100 if EMATrend = Above, 0 if EMATrend = Below, else 50; StructureScore = 100 if StructureTrend = Up, 0 if StructureTrend = Down, else 50
Calculation: Bias = Bull if BullShare >= bull threshold; Bear if BullShare <= bear threshold; otherwise Neutral
Calculation: OverallBullShare = (T1 weight * BullShare(T1, forming bar) + T2 weight * BullShare(T2, forming bar) + T3 weight * BullShare(T3, forming bar) + T4 weight * BullShare(T4, forming bar) + T5 weight * BullShare(T5, forming bar)) / (T1 weight + T2 weight + T3 weight + T4 weight + T5 weight)
Calculation: UnanimousBull = Bias(T1, forming bar) = Bull AND Bias(T2, forming bar) = Bull AND Bias(T3, forming bar) = Bull AND Bias(T4, forming bar) = Bull AND Bias(T5, forming bar) = Bull
Calculation: UnanimousBear = Bias(T1, forming bar) = Bear AND Bias(T2, forming bar) = Bear AND Bias(T3, forming bar) = Bear AND Bias(T4, forming bar) = Bear AND Bias(T5, forming bar) = Bear
Calculation: BullImpulse = close > open AND close - open >= impulse multiple * ATR(ATR length) AND close[1] < open[1]
Calculation: BearImpulse = close < open AND open - close >= impulse multiple * ATR(ATR length) AND close[1] > open[1]
Calculation: LatestOB = Bull or Bear, the type of the most recent bar where BullImpulse or BearImpulse is true (Bull for BullImpulse, Bear for BearImpulse); None if neither has occurred
Calculation: LatestFVG = Bull or Bear, the type of the most recent bar where low > high[2] or high < low[2] is true (Bull for low > high[2], Bear for high < low[2]); None if neither has occurred
Long: Bias(T1, forming bar) = Bull
Short: Bias(T1, forming bar) = Bear
Long: VolumeDelta(T1, forming bar) > 0
Short: VolumeDelta(T1, forming bar) < 0
Long: CVDTrend(T1, forming bar) = Rising
Short: CVDTrend(T1, forming bar) = Falling
Long: EMATrend(T1, forming bar) = Above
Short: EMATrend(T1, forming bar) = Below
Long: StructureTrend(T1, forming bar) = Up
Short: StructureTrend(T1, forming bar) = Down
Long: RSI(close, RSI length, T1, forming bar) >= RSI bullish level
Short: RSI(close, RSI length, T1, forming bar) <= RSI bearish level
Long: RSI(close, RSI length, T1, forming bar) > RSI midline AND RSI(close, RSI length, T1, forming bar) < RSI overbought level
Short: RSI(close, RSI length, T1, forming bar) < RSI midline AND RSI(close, RSI length, T1, forming bar) > RSI oversold level
Long: close(T1, forming bar) > EMA(close, shorter EMA length, T1, forming bar)
Short: close(T1, forming bar) < EMA(close, shorter EMA length, T1, forming bar)
Long: LatestFVG(T1, forming bar) = Bull
Short: LatestFVG(T1, forming bar) = Bear
Long: LatestOB(T1, forming bar) = Bull AND close(T1, forming bar) >= ValueWhen(BullImpulse, low[1], 0, T1, forming bar)
Short: LatestOB(T1, forming bar) = Bear AND close(T1, forming bar) <= ValueWhen(BearImpulse, high[1], 0, T1, forming bar)
Long: Bias(T2, forming bar) = Bull
Short: Bias(T2, forming bar) = Bear
Long: VolumeDelta(T2, forming bar) > 0
Short: VolumeDelta(T2, forming bar) < 0
Long: CVDTrend(T2, forming bar) = Rising
Short: CVDTrend(T2, forming bar) = Falling
Long: EMATrend(T2, forming bar) = Above
Short: EMATrend(T2, forming bar) = Below
Long: StructureTrend(T2, forming bar) = Up
Short: StructureTrend(T2, forming bar) = Down
Long: RSI(close, RSI length, T2, forming bar) >= RSI bullish level
Short: RSI(close, RSI length, T2, forming bar) <= RSI bearish level
Long: RSI(close, RSI length, T2, forming bar) > RSI midline AND RSI(close, RSI length, T2, forming bar) < RSI overbought level
Short: RSI(close, RSI length, T2, forming bar) < RSI midline AND RSI(close, RSI length, T2, forming bar) > RSI oversold level
Long: close(T2, forming bar) > EMA(close, shorter EMA length, T2, forming bar)
Short: close(T2, forming bar) < EMA(close, shorter EMA length, T2, forming bar)
Long: LatestFVG(T2, forming bar) = Bull
Short: LatestFVG(T2, forming bar) = Bear
Long: LatestOB(T2, forming bar) = Bull AND close(T2, forming bar) >= ValueWhen(BullImpulse, low[1], 0, T2, forming bar)
Short: LatestOB(T2, forming bar) = Bear AND close(T2, forming bar) <= ValueWhen(BearImpulse, high[1], 0, T2, forming bar)
Long: Bias(T3, forming bar) = Bull
Short: Bias(T3, forming bar) = Bear
Long: VolumeDelta(T3, forming bar) > 0
Short: VolumeDelta(T3, forming bar) < 0
Long: CVDTrend(T3, forming bar) = Rising
Short: CVDTrend(T3, forming bar) = Falling
Long: EMATrend(T3, forming bar) = Above
Short: EMATrend(T3, forming bar) = Below
Long: StructureTrend(T3, forming bar) = Up
Short: StructureTrend(T3, forming bar) = Down
Long: RSI(close, RSI length, T3, forming bar) >= RSI bullish level
Short: RSI(close, RSI length, T3, forming bar) <= RSI bearish level
Long: RSI(close, RSI length, T3, forming bar) > RSI midline AND RSI(close, RSI length, T3, forming bar) < RSI overbought level
Short: RSI(close, RSI length, T3, forming bar) < RSI midline AND RSI(close, RSI length, T3, forming bar) > RSI oversold level
Long: close(T3, forming bar) > EMA(close, shorter EMA length, T3, forming bar)
Short: close(T3, forming bar) < EMA(close, shorter EMA length, T3, forming bar)
Long: LatestFVG(T3, forming bar) = Bull
Short: LatestFVG(T3, forming bar) = Bear
Long: LatestOB(T3, forming bar) = Bull AND close(T3, forming bar) >= ValueWhen(BullImpulse, low[1], 0, T3, forming bar)
Short: LatestOB(T3, forming bar) = Bear AND close(T3, forming bar) <= ValueWhen(BearImpulse, high[1], 0, T3, forming bar)
Long: Bias(T4, forming bar) = Bull
Short: Bias(T4, forming bar) = Bear
Long: VolumeDelta(T4, forming bar) > 0
Short: VolumeDelta(T4, forming bar) < 0
Long: CVDTrend(T4, forming bar) = Rising
Short: CVDTrend(T4, forming bar) = Falling
Long: EMATrend(T4, forming bar) = Above
Short: EMATrend(T4, forming bar) = Below
Long: StructureTrend(T4, forming bar) = Up
Short: StructureTrend(T4, forming bar) = Down
Long: RSI(close, RSI length, T4, forming bar) >= RSI bullish level
Short: RSI(close, RSI length, T4, forming bar) <= RSI bearish level
Long: RSI(close, RSI length, T4, forming bar) > RSI midline AND RSI(close, RSI length, T4, forming bar) < RSI overbought level
Short: RSI(close, RSI length, T4, forming bar) < RSI midline AND RSI(close, RSI length, T4, forming bar) > RSI oversold level
Long: close(T4, forming bar) > EMA(close, shorter EMA length, T4, forming bar)
Short: close(T4, forming bar) < EMA(close, shorter EMA length, T4, forming bar)
Long: LatestFVG(T4, forming bar) = Bull
Short: LatestFVG(T4, forming bar) = Bear
Long: LatestOB(T4, forming bar) = Bull AND close(T4, forming bar) >= ValueWhen(BullImpulse, low[1], 0, T4, forming bar)
Short: LatestOB(T4, forming bar) = Bear AND close(T4, forming bar) <= ValueWhen(BearImpulse, high[1], 0, T4, forming bar)
Long: Bias(T5, forming bar) = Bull
Short: Bias(T5, forming bar) = Bear
Long: VolumeDelta(T5, forming bar) > 0
Short: VolumeDelta(T5, forming bar) < 0
Long: CVDTrend(T5, forming bar) = Rising
Short: CVDTrend(T5, forming bar) = Falling
Long: EMATrend(T5, forming bar) = Above
Short: EMATrend(T5, forming bar) = Below
Long: StructureTrend(T5, forming bar) = Up
Short: StructureTrend(T5, forming bar) = Down
Long: RSI(close, RSI length, T5, forming bar) >= RSI bullish level
Short: RSI(close, RSI length, T5, forming bar) <= RSI bearish level
Long: RSI(close, RSI length, T5, forming bar) > RSI midline AND RSI(close, RSI length, T5, forming bar) < RSI overbought level
Short: RSI(close, RSI length, T5, forming bar) < RSI midline AND RSI(close, RSI length, T5, forming bar) > RSI oversold level
Long: close(T5, forming bar) > EMA(close, shorter EMA length, T5, forming bar)
Short: close(T5, forming bar) < EMA(close, shorter EMA length, T5, forming bar)
Long: LatestFVG(T5, forming bar) = Bull
Short: LatestFVG(T5, forming bar) = Bear
Long: LatestOB(T5, forming bar) = Bull AND close(T5, forming bar) >= ValueWhen(BullImpulse, low[1], 0, T5, forming bar)
Short: LatestOB(T5, forming bar) = Bear AND close(T5, forming bar) <= ValueWhen(BearImpulse, high[1], 0, T5, forming bar)
Long: OverallBullShare crosses above bull threshold
Short: OverallBullShare crosses below bear threshold
Long: UnanimousBull AND NOT UnanimousBull[1]
Short: UnanimousBear AND NOT UnanimousBear[1]
Long: Bias(T3, forming bar) = Bull AND Bias(T3, forming bar)[1] = Bear
Short: Bias(T3, forming bar) = Bear AND Bias(T3, forming bar)[1] = Bull