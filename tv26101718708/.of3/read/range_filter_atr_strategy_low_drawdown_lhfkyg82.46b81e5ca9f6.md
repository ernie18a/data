Calculation: RangeMid = SMA(close, range length)
Calculation: RangeUpper = UpperBollingerBand(close, range length, range multiplier)
Calculation: RangeLower = LowerBollingerBand(close, range length, range multiplier)
Calculation: AvgTrueRange = ATR(ATR length)
Calculation: VolumeVsAverage = volume / SMA(volume, volume lookback)
Calculation: VolumeFilterPass = VolumeVsAverage > volume multiplier AND volume > minimum volume
Calculation: SwingRiskLong = close - (Lowest(low, 2 * swing lookback) - swing buffer)
Calculation: SwingRiskShort = (Highest(high, 2 * swing lookback) + swing buffer) - close
Calculation: TradingSessionActive = bar time within session window 1 OR bar time within session window 2 OR bar time within session window 3 OR bar time within session window 4
Calculation: PriceMomentum = MOM(close, momentum length)
Calculation: WeakMomentum = ABS(PriceMomentum) < ABS(SMA(PriceMomentum, momentum smoothing length)) * momentum threshold
Calculation: RsiValue = RSI(close, RSI length)
Calculation: PeakSinceEntry = Highest(high, bars since entry)
Calculation: TroughSinceEntry = Lowest(low, bars since entry)
Long: close crosses above RangeMid AND VolumeFilterPass AND SwingRiskLong > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Long: close crosses above RangeUpper + (RangeUpper - RangeLower) * band entry buffer AND close - RangeUpper >= AvgTrueRange * band minimum distance AND VolumeFilterPass AND SwingRiskLong > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Long: ABS(close - close[1]) >= AvgTrueRange * mid point minimum move AND ABS(close - RangeMid) <= RangeMid * mid point buffer / 100 AND close > close[1] AND close > open AND close > RangeMid AND VolumeFilterPass AND SwingRiskLong > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Long: close > RangeMid AND RsiValue < momentum zone upper RSI limit
Short: close crosses below RangeMid AND VolumeFilterPass AND SwingRiskShort > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Short: close crosses below RangeLower - (RangeUpper - RangeLower) * band entry buffer AND RangeLower - close >= AvgTrueRange * band minimum distance AND VolumeFilterPass AND SwingRiskShort > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Short: ABS(close - close[1]) >= AvgTrueRange * mid point minimum move AND ABS(close - RangeMid) <= RangeMid * mid point buffer / 100 AND close < close[1] AND close < open AND close < RangeMid AND VolumeFilterPass AND SwingRiskShort > AvgTrueRange * minimum stop ATR multiple AND TradingSessionActive
Short: close < RangeMid AND RsiValue > momentum zone lower RSI limit
Exit: Long, PeakSinceEntry >= entry price + AvgTrueRange * entry trail offset AND low <= PeakSinceEntry - AvgTrueRange * entry trail offset
Exit: Long, WeakMomentum AND PriceMomentum < 0
Exit: Long, RsiValue > RSI overbought level
Exit: Long, VolumeVsAverage < volume exit threshold
Exit: Long, bars since entry >= max hold bars
Exit: Short, TroughSinceEntry <= entry price - AvgTrueRange * entry trail offset AND high >= TroughSinceEntry + AvgTrueRange * entry trail offset
Exit: Short, WeakMomentum AND PriceMomentum > 0
Exit: Short, RsiValue < RSI oversold level
Exit: Short, VolumeVsAverage < volume exit threshold
Exit: Short, bars since entry >= max hold bars