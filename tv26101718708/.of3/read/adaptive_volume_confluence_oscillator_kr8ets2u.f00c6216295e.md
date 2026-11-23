Calculation: Efficiency = KaufmanEfficiencyRatio(close, efficiency length)
Calculation: ZScore(x, n) = (x - SMA(x, n)) / StDev(x, n)
Calculation: FlowState = flow coefficient * ZScore(HMA(volume if close > close[direction lag] else -volume, volume length) / HMA(volume, volume length), flow normalization length) + (1 - flow coefficient) * FlowState[1]
Calculation: Oscillator = SuperSmoother((1 - flow weight) * SuperSmoother(ZScore(close - LinearRegression(close, momentum length), normalization length), smoothing length) + flow weight * SuperSmoother(FlowState, smoothing length), smoothing length)
Calculation: OscillatorSignal = SuperSmoother(Oscillator, signal length)
Calculation: OversoldLevel = SMA(Oscillator, obos length) - obos multiplier * StDev(Oscillator, obos length)
Calculation: OverboughtLevel = SMA(Oscillator, obos length) + obos multiplier * StDev(Oscillator, obos length)
Calculation: RibbonZ = SuperSmoother(FlowState, ribbon fast length) / StDev(SuperSmoother(FlowState, ribbon fast length), ribbon normalization length)
Calculation: FanRank = sum over i < j of (+1 if EMA(close, fan base length + i * fan spacing) > EMA(close, fan base length + j * fan spacing), else -1), with i and j from 0 to fan count - 1
Calculation: Confluence = 100 * (number of TRUE among: Oscillator > 0, Oscillator > OscillatorSignal, FlowState > 0, FanRank > 0, close > VWAP((high + low + close) / 3), close > close[momentum length], close - EMA(close, momentum length) > 0 on T1 bars at last completed T1 bar) / 7
Calculation: VolumeRatio = volume / SMA(volume, climax length)
Calculation: LowPivotOsc = PivotLow(Oscillator, pivot length, pivot length)
Calculation: PrevLowPivotOsc = ValueWhen(LowPivotOsc is not na, LowPivotOsc, 1)
Calculation: PrevLowPivotPrice = ValueWhen(LowPivotOsc is not na, low[pivot length], 1)
Calculation: LowPivotSpacing = bars between this pivot low bar and the previous pivot low bar
Calculation: HighPivotOsc = PivotHigh(Oscillator, pivot length, pivot length)
Calculation: PrevHighPivotOsc = ValueWhen(HighPivotOsc is not na, HighPivotOsc, 1)
Calculation: PrevHighPivotPrice = ValueWhen(HighPivotOsc is not na, high[pivot length], 1)
Calculation: HighPivotSpacing = bars between this pivot high bar and the previous pivot high bar
Long: Oscillator crosses above OscillatorSignal AND Oscillator < OversoldLevel AND Confluence >= confluence gate AND Efficiency >= chop threshold AND RibbonZ < ribbon overbought level
Long: Efficiency >= chop threshold AND Confluence >= confluence gate
Long: Confluence >= strong level
Long: VolumeRatio > climax multiplier AND Oscillator < OversoldLevel
Long: LowPivotOsc is not na AND LowPivotSpacing <= max pivot spacing AND ((low[pivot length] < PrevLowPivotPrice AND LowPivotOsc > PrevLowPivotOsc) OR (low[pivot length] > PrevLowPivotPrice AND LowPivotOsc < PrevLowPivotOsc))
Short: Oscillator crosses below OscillatorSignal AND Oscillator > OverboughtLevel AND Confluence <= 100 - confluence gate AND Efficiency >= chop threshold AND RibbonZ > -ribbon overbought level
Short: Efficiency >= chop threshold AND Confluence <= 100 - confluence gate
Short: Confluence <= 100 - strong level
Short: VolumeRatio > climax multiplier AND Oscillator > OverboughtLevel
Short: HighPivotOsc is not na AND HighPivotSpacing <= max pivot spacing AND ((high[pivot length] > PrevHighPivotPrice AND HighPivotOsc < PrevHighPivotOsc) OR (high[pivot length] < PrevHighPivotPrice AND HighPivotOsc > PrevHighPivotOsc))