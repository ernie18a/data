Calculation: NewPeriod = the bar is the first chart bar of a new T3 period
Calculation: InSession(S) = the time of day of datetime is within session window S
Calculation: SessionHigh(S) = highest high of the bars in the current T3 period, up to and including the current bar, where InSession(S) = true
Calculation: SessionLow(S) = lowest low of the bars in the current T3 period, up to and including the current bar, where InSession(S) = true
Calculation: SessionOpen(S) = open of the earliest bar in the current T3 period, up to and including the current bar, where InSession(S) = true
Calculation: SessionClose(S) = close of the latest bar in the current T3 period, up to and including the current bar, where InSession(S) = true
Calculation: SessionMidpoint(S) = (SessionHigh(S) + SessionLow(S)) / 2
Calculation: EarlierBullBreak(S) = (NewPeriod = false) AND (EarlierBullBreak(S)[1] = true OR (InSession(S)[1] = true AND close[1] > SessionHigh(S)[1]))
Calculation: EarlierBearBreak(S) = (NewPeriod = false) AND (EarlierBearBreak(S)[1] = true OR (InSession(S)[1] = true AND close[1] < SessionLow(S)[1]))
Calculation: Position(T) = (close - Low(T)) / (High(T) - Low(T)), where High(T) and Low(T) are the high and low of the bar before the last completed T bar, evaluated on chart bars
Calculation: PositionMean = mean of Position(T1), Position(T2), Position(T3), Position(T4), Position(T5), skipping NA values
Calculation: VolumeRatio = volume / SMA(volume, VolumeLookback)
Calculation: VolumeBurst = Burst if VolumeRatio > BurstThreshold, else Normal if VolumeRatio > NormalThreshold, else Quiet
Long: InSession(S1) = true AND close > SessionHigh(S1) AND EarlierBullBreak(S1) = false
Short: InSession(S1) = true AND close < SessionLow(S1) AND EarlierBearBreak(S1) = false
Long: InSession(S2) = true AND close > SessionHigh(S2) AND EarlierBullBreak(S2) = false
Short: InSession(S2) = true AND close < SessionLow(S2) AND EarlierBearBreak(S2) = false
Long: InSession(S3) = true AND close > SessionHigh(S3) AND EarlierBullBreak(S3) = false
Short: InSession(S3) = true AND close < SessionLow(S3) AND EarlierBearBreak(S3) = false
Long: SessionClose(S1) > SessionOpen(S1) * (1 + DriveBand)
Short: SessionClose(S1) < SessionOpen(S1) * (1 - DriveBand)
Long: SessionClose(S1) > SessionOpen(S1) AND SessionClose(S1) <= SessionOpen(S1) * (1 + DriveBand)
Short: SessionClose(S1) < SessionOpen(S1) AND SessionClose(S1) >= SessionOpen(S1) * (1 - DriveBand)
Long: SessionClose(S1) > SessionMidpoint(S1)
Short: SessionClose(S1) < SessionMidpoint(S1)
Long: SessionClose(S2) > SessionOpen(S2) * (1 + DriveBand)
Short: SessionClose(S2) < SessionOpen(S2) * (1 - DriveBand)
Long: SessionClose(S2) > SessionOpen(S2) AND SessionClose(S2) <= SessionOpen(S2) * (1 + DriveBand)
Short: SessionClose(S2) < SessionOpen(S2) AND SessionClose(S2) >= SessionOpen(S2) * (1 - DriveBand)
Long: SessionClose(S2) > SessionMidpoint(S2)
Short: SessionClose(S2) < SessionMidpoint(S2)
Long: SessionClose(S3) > SessionOpen(S3) * (1 + DriveBand)
Short: SessionClose(S3) < SessionOpen(S3) * (1 - DriveBand)
Long: SessionClose(S3) > SessionOpen(S3) AND SessionClose(S3) <= SessionOpen(S3) * (1 + DriveBand)
Short: SessionClose(S3) < SessionOpen(S3) AND SessionClose(S3) >= SessionOpen(S3) * (1 - DriveBand)
Long: SessionClose(S3) > SessionMidpoint(S3)
Short: SessionClose(S3) < SessionMidpoint(S3)
Long: PositionMean < LowerPosition AND VolumeRatio > VolumeRatioThreshold AND VolumeBurst = High
Short: PositionMean > UpperPosition AND VolumeRatio > VolumeRatioThreshold AND VolumeBurst = High
Long: PositionMean > UpperPosition AND VolumeRatio < VolumeRatioThreshold
Short: PositionMean < LowerPosition AND VolumeRatio < VolumeRatioThreshold