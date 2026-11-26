Calculation: Percentile(source, lookback, level) = element at zero-based index floor(level × (lookback − 1) / 100) of source[0] through source[lookback − 1] sorted ascending
Calculation: ShortMA = SMA(close, short MA lookback)
Calculation: LongMA = SMA(close, long MA lookback)
Calculation: PctMove = |close − close[1]| / close[1] × 100
Calculation: BandWidth = BBWidth(close, Bollinger lookback, Bollinger multiplier)
Calculation: BandWidthPercentile = Percentile(BandWidth, percentile lookback, percentile level)
Calculation: DirectionScore = direction value 1 if close > ShortMA AND ShortMA > LongMA AND ShortMA > ShortMA[1] AND close > high − (high − low) × close position fraction; else direction value 2 if close > ShortMA AND ShortMA > LongMA; else direction value 3 if close > ShortMA AND ShortMA < LongMA; else direction value 4 if close < ShortMA AND ShortMA > LongMA; else direction value 5 if close < ShortMA AND ShortMA < LongMA AND ShortMA < ShortMA[1] AND close < low + (high − low) × close position fraction; else direction value 6 if close < ShortMA AND ShortMA < LongMA; else direction value 7
Calculation: RsiValue = RSI(close, RSI lookback)
Calculation: MomentumScore = momentum value 1 if RsiValue ≥ RSI level 1 AND RsiValue > RsiValue[1] AND close > close[1] × (1 + close move threshold); else momentum value 2 if RsiValue ≥ RSI level 2 AND RsiValue < RSI level 1 AND RsiValue > RsiValue[1]; else momentum value 3 if RsiValue ≥ RSI level 3 AND RsiValue ≤ RSI level 2 AND PctMove < momentum move cutoff; else momentum value 4 if RsiValue ≥ RSI level 4 AND RsiValue < RSI level 3 AND RsiValue < RsiValue[1]; else momentum value 5 if RsiValue ≥ RSI level 5 AND RsiValue < RSI level 4 AND RsiValue < RsiValue[1] AND close < close[1] × (1 − close move threshold); else momentum value 6 if RsiValue < RSI level 5 OR RsiValue > RSI level 6; else momentum value 7
Calculation: CoilScore = coil value 1 if PctMove < coil move cutoff AND PctMove[1] < coil move cutoff AND PctMove[2] < coil move cutoff AND BandWidth < BandWidthPercentile × coil width factor 1; else coil value 2 if PctMove < coil move cutoff AND PctMove[1] < coil move cutoff AND BandWidth < BandWidthPercentile × coil width factor 2; else coil value 3 if PctMove ≤ coil move level 1 AND BandWidth ≥ BandWidthPercentile × coil width factor 2 AND BandWidth ≤ BandWidthPercentile × coil width factor 3; else coil value 4 if PctMove > coil move level 2 AND BandWidth > BandWidthPercentile × coil width factor 4; else coil value 5 if PctMove > coil move level 3 AND BandWidth > BandWidthPercentile × coil width factor 5; else coil value 6 if PctMove > coil move level 4; else coil value 7
Calculation: CmfValue = CMF(CMF lookback)
Calculation: MfiValue = MFI(close, MFI lookback)
Calculation: FlowScore = flow value 1 if CmfValue > CMF level 1 AND MfiValue > MFI level 1; else flow value 2 if CmfValue > CMF level 2 AND MfiValue ≥ MFI level 2; else flow value 3 if CmfValue ≥ CMF level 3 AND CmfValue ≤ CMF level 2 AND MfiValue ≥ MFI level 3 AND MfiValue < MFI level 2; else flow value 4 if CmfValue ≥ CMF level 4 AND CmfValue < CMF level 3; else flow value 5 if CmfValue < CMF level 4 AND MfiValue < MFI level 4; else flow value 6 if CmfValue < CMF level 5 AND MfiValue < MFI level 5; else flow value 7
Calculation: TrendScore = (DirectionScore + MomentumScore + CoilScore + FlowScore) / 4
Calculation: RangeAverage = SMA(high − low, volume lookback)
Calculation: RangeToAverage = (high − low) / RangeAverage
Calculation: VolumeAverage = SMA(volume, volume lookback)
Calculation: VolumeToAverage = volume / VolumeAverage
Calculation: DensityScore = density value 1 if RangeToAverage < range level 1 AND VolumeToAverage < volume level 1; else density value 2 if RangeToAverage < range level 2 AND VolumeToAverage < volume level 2; else density value 3 if RangeToAverage ≥ range level 2 AND RangeToAverage ≤ range level 3; else density value 4 if RangeToAverage > range level 3 AND RangeToAverage ≤ range level 4; else density value 5 if RangeToAverage > range level 4 AND RangeToAverage ≤ range level 5; else density value 6 if RangeToAverage > range level 5 AND VolumeToAverage > volume level 3; else density value 7
Calculation: HighRef = Highest(high, breakout lookback)
Calculation: LowRef = Lowest(low, breakout lookback)
Calculation: BreakdownScore = breakdown value 1 if close > HighRef × (1 + breakout band) AND volume > VolumeAverage × breakout volume multiple; else breakdown value 2 if high > HighRef AND NOT (close > HighRef × (1 + breakout band)); else breakdown value 3 if (HighRef − close) / HighRef < breakout band OR (close − LowRef) / close < breakout band; else breakdown value 4 if high > HighRef AND close ≤ HighRef AND volume > VolumeAverage × fake breakout volume multiple; else breakdown value 5 if close < LowRef × (1 − breakout band) AND volume > VolumeAverage × breakout volume multiple; else breakdown value 6
Calculation: BodyShare = |close − open| / (high − low)
Calculation: RangeToAtr = (high − low) / ATR(ATR lookback)
Calculation: LongShadows = (high − max(close, open)) > wick factor × |close − open| AND (min(close, open) − low) > wick factor × |close − open|
Calculation: WickScore = wick value 1 if LongShadows AND LongShadows[1] AND LongShadows[2] AND high − low > Percentile(high − low, percentile lookback, percentile level) × range percentile factor; else wick value 2 if LongShadows OR (BodyShare < body share level 1 AND RangeToAtr > range to ATR level 1); else wick value 3 if BodyShare ≥ body share level 1 AND BodyShare ≤ body share level 2; else wick value 4 if BodyShare > body share level 2 AND BodyShare ≤ body share level 3; else wick value 5 if BodyShare > body share level 3 AND RangeToAtr < range to ATR level 2; else wick value 6 if RangeToAtr < tiny range level; else wick value 7
Calculation: NearHighTest = close > HighRef × (1 − wide test band) AND close < HighRef × (1 + narrow test band)
Calculation: NearLowTest = close < LowRef × (1 + wide test band) AND close > LowRef × (1 − narrow test band)
Calculation: LevelScore = level value 1 if (NearHighTest AND NearHighTest[1] AND NearHighTest[2]) OR (NearLowTest AND NearLowTest[1] AND NearLowTest[2]); else level value 2 if NearHighTest OR NearLowTest; else level value 3 if min((HighRef − close) / close × 100, (close − LowRef) / close × 100) < distance level 1; else level value 4 if min((HighRef − close) / close × 100, (close − LowRef) / close × 100) < distance level 2; else level value 5 if min((HighRef − close) / close × 100, (close − LowRef) / close × 100) < distance level 3; else level value 6
Calculation: StructureScore = (DensityScore + BreakdownScore + WickScore + LevelScore) / 4
Long: PivotLow(low, left pivot bars, right pivot bars) is not na
Short: PivotHigh(high, left pivot bars, right pivot bars) is not na
Long: TrendScore ≥ trend bull threshold
Short: TrendScore < trend bear threshold
Long: StructureScore ≥ structure bull threshold
Short: StructureScore < structure bear threshold