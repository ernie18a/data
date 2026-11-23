Calculation: LevelHigh = IF(use T1 level, high of last completed T1 bar taken on chart bars, Highest(high[1], structure lookback))
Calculation: LevelLow = IF(use T1 level, low of last completed T1 bar taken on chart bars, Lowest(low[1], structure lookback))
Calculation: FlowRatio = SUM(volume * (2 * (close - low) / (high - low) - 1), pressure lookback) / (pressure lookback * SMA(volume[1], volume lookback)), per-bar term is 0 when high = low
Calculation: UpScore = COUNT(volume / SMA(volume[1], volume lookback) >= volume multiplier, close > open AND (close - open) / ATR(high, low, close, ATR lookback) >= body ATR multiplier, FlowRatio >= pressure threshold, (close - LevelHigh) / ATR(high, low, close, ATR lookback) >= close extension multiplier)
Calculation: DownScore = COUNT(volume / SMA(volume[1], volume lookback) >= volume multiplier, close < open AND (open - close) / ATR(high, low, close, ATR lookback) >= body ATR multiplier, FlowRatio <= -pressure threshold, (LevelLow - close) / ATR(high, low, close, ATR lookback) >= close extension multiplier)
Calculation: QualifiedBreak = (close > LevelHigh AND UpScore >= zone min score) OR (close < LevelLow AND DownScore >= zone min score)
Calculation: AnchorSide = IF(QualifiedBreak, IF(close > LevelHigh, 1, -1), AnchorSide[1])
Calculation: AnchorLevel = IF(QualifiedBreak, IF(close > LevelHigh, LevelHigh, LevelLow), AnchorLevel[1])
Calculation: AnchorATR = IF(QualifiedBreak, ATR(high, low, close, ATR lookback), AnchorATR[1])
Calculation: AnchorAge = IF(QualifiedBreak, 0, AnchorAge[1] + 1)
Calculation: Live = AnchorAge <= zone expiry bars AND NOT Failed[1]
Calculation: ZoneFail = Live AND AnchorAge > 0 AND AnchorSide * (close - AnchorLevel) < -zone fail tolerance * AnchorATR
Calculation: Failed = IF(QualifiedBreak, false, Failed[1] OR ZoneFail)
Calculation: ZoneRearm = Live AND AnchorAge > 0 AND AnchorSide * (close - AnchorLevel) >= zone rearm distance * AnchorATR
Calculation: ZoneBounce = Live AND AnchorAge > 0 AND Armed[1] AND NOT ZoneFail AND ((AnchorSide = 1 AND low <= AnchorLevel AND close >= AnchorLevel) OR (AnchorSide = -1 AND high >= AnchorLevel AND close <= AnchorLevel))
Calculation: Armed = IF(QualifiedBreak, false, IF(ZoneFail OR ZoneBounce, false, IF(ZoneRearm, true, Armed[1])))
Long: close > LevelHigh AND UpScore >= mark min score
Short: close < LevelLow AND DownScore >= mark min score
Long: ZoneBounce AND AnchorSide = 1
Short: ZoneBounce AND AnchorSide = -1
Exit: long, ZoneFail AND AnchorSide = 1
Exit: short, ZoneFail AND AnchorSide = -1