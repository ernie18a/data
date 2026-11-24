Calculation: RawScore(Ti) = sign(close - EMA(close, fast lookback)) + sign(RSI(close, RSI lookback) - EMA(RSI(close, RSI lookback), RSI signal lookback)), computed on Ti bars and carried to chart bars; use the forming Ti bar in realtime and the latest completed Ti bar historically, for five timeframes ordered T1 shortest to T5 longest
Calculation: CompositeScore = ScoreScale × Σ(i=1..5)[Weight_i × RawScore(Ti)] / Σ(i=1..5)Weight_i
Calculation: EffectiveThreshold = SignalThreshold × VolumeMultiplier when the volume filter is enabled and chart-bar volume ≤ SMA(volume, volume lookback); otherwise SignalThreshold
Long: CompositeScore > EffectiveThreshold AND CompositeScore[1] ≤ EffectiveThreshold[1]
Short: CompositeScore < −EffectiveThreshold AND CompositeScore[1] ≥ −EffectiveThreshold[1]