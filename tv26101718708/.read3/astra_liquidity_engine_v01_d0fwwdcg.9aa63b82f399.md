Calculation: SmoothedMomentum = EMA(fast weight * (RSI(HLC3, fast RSI length) - 50) + medium weight * (RSI(HLC3, medium RSI length) - 50) + slow weight * (RSI(HLC3, slow RSI length) - 50), energy smoothing length)
Calculation: NormMomentum = 0 if StdDev(SmoothedMomentum, stdev length) = 0, else min(clamp limit, max(-clamp limit, SmoothedMomentum / StdDev(SmoothedMomentum, stdev length) * normalization scale))
Calculation: MomentumExpansion = abs(NormMomentum) > abs(NormMomentum)[1] AND abs(NormMomentum)[1] > abs(NormMomentum)[2]
Calculation: MomentumAboveAvg = abs(NormMomentum) > SMA(abs(NormMomentum), energy average length)
Calculation: HighVolume = volume > SMA(volume, volume lookback) * (1 + volatility factor), where volatility factor = ATR(atr length) / SMA(ATR(atr length), atr average length) if that SMA is nonzero, else 1
Calculation: CompressionBreakout = NOT MomentumAboveAvg[1] AND MomentumExpansion AND HighVolume
Calculation: Pullback = MomentumAboveAvg AND abs(NormMomentum) < abs(NormMomentum)[1] AND (high - low) < SMA(high - low, pullback average length) * pullback ratio
Calculation: HeatShown = MomentumAboveAvg if auto mode flag is true, else show heat flag
Calculation: HighSweep = high > Highest(high, liquidity lookback) AND close < Highest(high, liquidity lookback)
Calculation: LowSweep = low < Lowest(low, liquidity lookback) AND close > Lowest(low, liquidity lookback)
Calculation: ValueLevel = close
Long: LowSweep
Short: HighSweep
Long: HighSweep AND NOT MomentumExpansion AND close > Highest(high, liquidity lookback)
Short: LowSweep AND NOT MomentumExpansion AND close < Lowest(low, liquidity lookback)
Long: CompressionBreakout AND close > Highest(high, structure length)[1]
Short: CompressionBreakout AND close < Lowest(low, structure length)[1]
Long: Pullback AND NormMomentum > 0
Short: Pullback AND NormMomentum < 0
Long: Pullback AND NormMomentum > 0 AND MomentumExpansion AND HighVolume
Short: Pullback AND NormMomentum < 0 AND MomentumExpansion AND HighVolume
Long: NormMomentum(T1, last completed bar) > 0
Short: NormMomentum(T1, last completed bar) < 0
Long: HeatShown AND NormMomentum > 0
Short: HeatShown AND NormMomentum <= 0
Long: close > ValueLevel AND ValueLevel > ValueLevel[1]
Short: close < ValueLevel AND ValueLevel < ValueLevel[1]