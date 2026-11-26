Calculation: InSession = bar time is within session window
Calculation: SessionHigh = highest(high or max(open, close) per range source parameter, over InSession bars since latest session start)
Calculation: SessionLow = lowest(low or min(open, close) per range source parameter, over InSession bars since latest session start)
Calculation: SessionRange = SessionHigh - SessionLow
Calculation: VolumeRatio = volume / max(SMA(volume, volume lookback), volume floor)
Calculation: LongTrail = max(LongTrail[1], close - ATR(trail ATR length) * trail multiplier) while long, else na
Calculation: ShortTrail = min(ShortTrail[1], close + ATR(trail ATR length) * trail multiplier) while short, else na
Long: position side flat on prior bar AND close > SessionHigh + SessionRange * minimum break fraction AND (volume lift not required OR VolumeRatio >= volume threshold)
Short: position side flat on prior bar AND close < SessionLow - SessionRange * minimum break fraction AND (volume lift not required OR VolumeRatio >= volume threshold)
Exit: long, close < LongTrail
Exit: short, close > ShortTrail
Exit: long, InSession AND NOT InSession[1]
Exit: short, InSession AND NOT InSession[1]