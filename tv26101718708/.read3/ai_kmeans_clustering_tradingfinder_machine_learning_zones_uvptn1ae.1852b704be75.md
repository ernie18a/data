Calculation: BodyFraction = abs(close - open) / (high - low)
Calculation: UpperWickFraction = (high - max(open, close)) / (high - low)
Calculation: LowerWickFraction = (min(open, close) - low) / (high - low)
Calculation: NormAtr = ATR(high, low, close, ATR length) / close
Calculation: ZoneTolerance = max(minimum near-zone distance × near-zone multiple, NormAtr[1] × ATR zone multiple)
Calculation: RawCenter = the K-means center nearest to close, where K-means (zone cluster count clusters, K-means iteration limit, K-means tolerance, centers seeded at evenly spaced positions of the sorted set) clusters the 1-D set of confirmed pivot highs and lows (pivot length bars on each side) together with the highs and lows of every zone sampling step-th bar over zone lookback bars
Calculation: ZoneTarget = RawCenter if abs(close - RawCenter) + ATR(high, low, close, ATR length) × switch multiple < abs(close - ZoneTarget[1]), otherwise ZoneTarget[1]
Calculation: ZoneLevel = EMA(ZoneTarget, zone smoothing length)
Calculation: EmaSpread = (EMA(close, shorter lookback) - EMA(close, longer lookback)) / close
Calculation: EmaSlope = (EMA(close, longer lookback) - EMA(close, longer lookback)[slope lag]) / close
Calculation: RelVolume = volume / SMA(volume, volume lookback)
Calculation: DominantCenter = the de-standardized center of the cluster most frequent among the last state window bars, from K-means (state cluster count clusters, K-means iteration limit, K-means tolerance, seeded by nearest-to-origin then farthest-point selection) over z-scored (EmaSpread, EmaSlope, RelVolume) vectors of the last state lookback bars
Calculation: StateScore = bias weight × DominantCenter.EmaSpread + slope weight × DominantCenter.EmaSlope
Calculation: StateBand = band multiple × SMA(NormAtr, state lookback)
Long: BodyFraction > breakout body threshold AND open < ZoneLevel AND close > ZoneLevel
Long: close > open AND LowerWickFraction > rejection wick threshold AND LowerWickFraction > UpperWickFraction AND LowerWickFraction > BodyFraction × wick-to-body multiple AND (abs(low - ZoneLevel) / close <= ZoneTolerance OR (low <= ZoneLevel AND close > ZoneLevel))
Long: close > open AND BodyFraction > momentum body threshold AND close > high[1] AND StateScore > StateBand
Long: StateScore > StateBand AND DominantCenter.RelVolume > high-volume threshold
Short: BodyFraction > breakout body threshold AND open > ZoneLevel AND close < ZoneLevel
Short: close < open AND UpperWickFraction > rejection wick threshold AND UpperWickFraction > LowerWickFraction AND UpperWickFraction > BodyFraction × wick-to-body multiple AND (abs(high - ZoneLevel) / close <= ZoneTolerance OR (high >= ZoneLevel AND close < ZoneLevel))
Short: close < open AND BodyFraction > momentum body threshold AND close < low[1] AND StateScore < -StateBand
Short: StateScore < -StateBand AND DominantCenter.RelVolume > high-volume threshold