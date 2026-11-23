Calculation: VolumeSpike = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: BullScore = trend weight * (EMA(close, shorter EMA lookback, T1, last completed bar) > EMA(close, longer EMA lookback, T1, last completed bar) AND close > EMA(close, shorter EMA lookback, T1, last completed bar)) + momentum weight * (RSI(close, RSI lookback) > RSI midline AND RSI(close, RSI lookback) < upper RSI bound) + volume weight * (VolumeSpike AND close > open)
Calculation: BearScore = trend weight * (EMA(close, shorter EMA lookback, T1, last completed bar) < EMA(close, longer EMA lookback, T1, last completed bar) AND close < EMA(close, shorter EMA lookback, T1, last completed bar)) + momentum weight * (RSI(close, RSI lookback) < RSI midline AND RSI(close, RSI lookback) > lower RSI bound) + volume weight * (VolumeSpike AND close < open)
Calculation: Spread = BullScore - BearScore
Calculation: ConvictionRising = SMA(ABS(Spread), history length - floor(history length / 2)) > SMA(ABS(Spread), floor(history length / 2))[history length - floor(history length / 2)] + conviction margin
Calculation: RS = sector index close / benchmark index close, T2, last completed bar
Long: BullScore >= strong bias threshold
Long: BullScore >= weak bias threshold AND BullScore < strong bias threshold AND BullScore > BearScore
Long: BullScore >= strong bias threshold AND (BullScore[1] < strong bias threshold OR (ConvictionRising AND NOT ConvictionRising[1])) AND bars since last alert >= alert cooldown
Long: Spread > spark color threshold
Long: RS >= RS[longer RS lookback] AND RS >= RS[shorter RS lookback]
Short: BearScore >= strong bias threshold
Short: BearScore >= weak bias threshold AND BearScore < strong bias threshold AND BearScore >= BullScore
Short: BearScore >= strong bias threshold AND (BearScore[1] < strong bias threshold OR (ConvictionRising AND NOT ConvictionRising[1])) AND bars since last alert >= alert cooldown
Short: Spread < -spark color threshold
Short: RS < RS[longer RS lookback] AND RS < RS[shorter RS lookback]
Exit: long, RS >= RS[longer RS lookback] AND RS < RS[shorter RS lookback]