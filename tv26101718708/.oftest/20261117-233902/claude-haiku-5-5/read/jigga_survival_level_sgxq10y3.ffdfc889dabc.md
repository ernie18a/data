Calculation: MacdLine = EMA(close, fast EMA lookback) - EMA(close, slow EMA lookback)
Calculation: MacdSignal = EMA(MacdLine, MACD signal lookback)
Calculation: MacdHist = MacdLine - MacdSignal
Calculation: MacdZone = (MacdLine > 0 ? 0 : -1) + (MacdLine > MacdSignal ? 1 : 0)
Calculation: MacdHistTrend = (MacdHist >= 0 ? 0 : -1) + (MacdHist > MacdHist[1] ? 1 : 0)
Calculation: SmoothRsi = EMA(RSI(close, length A), RSI smoothing lookback)
Calculation: RsiZone = SmoothRsi > upper threshold ? 1 : SmoothRsi < lower threshold ? -1 : 0
Calculation: SmoothWilliams = EMA(Williams %R(high, low, close, length B), Williams smoothing lookback)
Calculation: WilliamsZone = SmoothWilliams > -lower threshold ? 1 : SmoothWilliams < -upper threshold ? -1 : 0
Calculation: Cmf = CMF(high, low, close, volume, length B)
Calculation: CmfZone = Cmf > CMF threshold ? 1 : Cmf < -CMF threshold ? -1 : 0
Calculation: EmaTrend = EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) ? 1 : -1
Calculation: Adx = ADX(length A, length A)
Calculation: AdxTrendPoints = Adx > EMA(Adx, ADX EMA lookback) ? (close > EMA(close, close EMA lookback) ? 1 : -1) : 0
Calculation: Score = MacdZone + MacdHistTrend + RsiZone + EmaTrend + AdxTrendPoints + WilliamsZone + CmfZone + SuperTrend direction(high, low, close, ATR length, SuperTrend multiplier)
Calculation: ZeroedScore = ((Score >= 0 AND Score[1] <= 0) OR (Score <= 0 AND Score[1] >= 0)) ? 0 : Score
Calculation: Level = Level[1] != 0 ? 0 : (ZeroedScore[1] < 0 AND ZeroedScore >= 0) ? high * up multiplier : (ZeroedScore[1] > 0 AND ZeroedScore <= 0) ? low * down multiplier : 0
Calculation: LastCrossUp = (ZeroedScore[1] < 0 AND ZeroedScore >= 0) ? true : (ZeroedScore[1] > 0 AND ZeroedScore <= 0) ? false : LastCrossUp[1], with initial value true
Long: (high > Level AND LastCrossUp = true) OR (ZeroedScore[1] > 0 AND ZeroedScore > 0)
Exit: long, (low < Level AND LastCrossUp = false) OR (ZeroedScore[1] < 0 AND ZeroedScore < 0)