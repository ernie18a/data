Calculation: MacdLine = MACD(close, shorter MACD lookback, longer MACD lookback)
Calculation: MacdSignal = EMA(MacdLine, MACD signal lookback)
Calculation: MacdHist = MacdLine - MacdSignal
Calculation: Trend = MacdLine > 0 ? (MacdLine > MacdSignal ? 1 : 0) : (MacdLine > MacdSignal ? 0 : -1)
Calculation: Momentum = MacdHist >= 0 ? (MacdHist > MacdHist[1] ? 1 : 0) : (MacdHist > MacdHist[1] ? 0 : -1)
Calculation: RsiSmooth = EMA(RSI(close, RSI lookback), RSI smoothing lookback)
Calculation: Oscillator = RsiSmooth > upper threshold ? 1 : (RsiSmooth < lower threshold ? -1 : 0)
Calculation: Cross = EMA(close, shorter cross lookback) > EMA(close, longer cross lookback) ? 1 : -1
Calculation: Adx = ADX(high, low, close, DI lookback, ADX smoothing lookback)
Calculation: Strength = Adx > EMA(Adx, ADX gate lookback) ? (close > EMA(close, close gate lookback) ? 1 : -1) : 0
Calculation: WrSmooth = EMA(WilliamsR(high, low, close, Williams lookback), Williams smoothing lookback)
Calculation: WilliamsZone = WrSmooth > -lower threshold ? 1 : (WrSmooth < -upper threshold ? -1 : 0)
Calculation: Cmf = CMF(high, low, close, volume, CMF lookback)
Calculation: Flow = Cmf > CMF threshold ? 1 : (Cmf < -CMF threshold ? -1 : 0)
Calculation: Score = Trend + Momentum + Oscillator + Cross + Strength + WilliamsZone + Flow + SuperTrend direction(high, low, close, ATR lookback, band multiplier)
Calculation: Filtered = ((Score > 0 AND Score[1] > 0) OR (Score < 0 AND Score[1] < 0)) ? Score : 0
Calculation: LevelColor = (Filtered[1] < 0 AND Filtered >= 0) ? green : ((Filtered[1] > 0 AND Filtered <= 0) ? red : LevelColor[1]), initially green
Calculation: Level = Level[1] != 0 ? 0 : ((Filtered[1] < 0 AND Filtered >= 0) ? high * upper multiplier : ((Filtered[1] > 0 AND Filtered <= 0) ? low * lower multiplier : 0))
Long: (high > Level AND LevelColor = green) OR (Filtered > 0 AND Filtered[1] > 0)
Exit: long, (low < Level AND LevelColor = red) OR (Filtered < 0 AND Filtered[1] < 0)