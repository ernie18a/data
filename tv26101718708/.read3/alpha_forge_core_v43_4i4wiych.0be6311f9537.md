Calculation: Center = ZLEMA(close, trend length)
Calculation: Atr = ATR(trend length)
Calculation: Band = Highest(Atr, band window multiple * trend length) * band multiplier
Calculation: Ceiling = Center + Band
Calculation: Floor = Center - Band
Calculation: TrendState = 1 when close crosses above Ceiling, -1 when close crosses below Floor, otherwise TrendState[1]
Calculation: Stretch = (close - Center) / Band, or 0 when Band = 0
Calculation: Oscillator = EMA(Stretch, oscillator smoothing length)
Calculation: SignalLine = EMA(Oscillator, signal smoothing length), with signal smoothing length shorter than oscillator smoothing length
Calculation: Histogram = Oscillator - SignalLine
Calculation: UpConfirm = Oscillator > SignalLine AND Histogram > Histogram[1]
Calculation: DownConfirm = Oscillator < SignalLine AND Histogram < Histogram[1]
Calculation: MomentumUp = Oscillator > minimum momentum AND UpConfirm
Calculation: MomentumDown = Oscillator < -minimum momentum AND DownConfirm
Calculation: HigherCenter = ZLEMA(close, trend length, T1, last completed bar)
Calculation: HigherBias = 1 when close(T1, last completed bar) > HigherCenter AND HigherCenter > HigherCenter[1], -1 when close(T1, last completed bar) < HigherCenter AND HigherCenter < HigherCenter[1], otherwise 0
Calculation: HigherOkLong = NOT HTF filter flag OR HigherBias != -1
Calculation: HigherOkShort = NOT HTF filter flag OR HigherBias != 1
Calculation: SpacingOk = no UpBreak or DownBreak on an earlier bar, OR bars since the latest earlier UpBreak or DownBreak >= min bars between structure
Calculation: UpBreak = close crosses above SwingHigh AND (close - SwingHigh) > Atr * structure break multiple AND SpacingOk, where SwingHigh = most recent non-NA PivotHigh(high, pivot length, pivot length)
Calculation: DownBreak = close crosses below SwingLow AND (SwingLow - close) > Atr * structure break multiple AND SpacingOk, where SwingLow = most recent non-NA PivotLow(low, pivot length, pivot length)
Calculation: StructureState = 1 when UpBreak, -1 when DownBreak, otherwise StructureState[1]
Calculation: ExtremeRecoverUp = Oscillator[1] < -reversal extreme AND UpConfirm
Calculation: ExtremeRecoverDown = Oscillator[1] > reversal extreme AND DownConfirm
Calculation: BasisUp = close crosses above Center
Calculation: BasisDown = close crosses below Center
Calculation: LongEntry = ((((TrendState = 1 AND StructureState = 1 AND Center > Center[1] AND BasisUp AND MomentumUp AND HigherOkLong AND Stretch < max stretch) OR (ExtremeRecoverUp AND BasisUp AND Oscillator > Oscillator[1] AND close > open AND (close - open) > (high - low) * bull body fraction AND HigherOkLong AND NOT (Center < Center[1] AND close < Center AND close < Floor) AND (NOT stock mode flag OR (UpBreak AND StructureState[1] = -1)))) AND (NOT stock mode flag OR (HigherBias != 0 AND MomentumUp AND TrendState = 1 AND StructureState = 1))) OR (stock mode flag AND TrendState = 1 AND StructureState = 1 AND close > Center AND close[1] < Center AND UpConfirm)) AND (NOT confirmation flag OR close > close[1]) AND count(TrendState = 1, HigherBias = 1, StructureState = 1, MomentumUp, UpConfirm) >= minimum score AND NOT LongLock[1]
Calculation: ShortEntry = (((TrendState = -1 AND StructureState = -1 AND Center < Center[1] AND BasisDown AND MomentumDown AND HigherOkShort AND Stretch > -max stretch) OR (ExtremeRecoverDown AND BasisDown AND Oscillator < Oscillator[1] AND close < open AND (open - close) > (high - low) * bear body fraction AND HigherOkShort AND NOT (Center > Center[1] AND close > Center AND close > Ceiling) AND (NOT stock mode flag OR (DownBreak AND StructureState[1] = 1)))) AND (NOT stock mode flag OR (HigherBias != 0 AND MomentumDown AND TrendState = -1 AND StructureState = -1))) AND (NOT confirmation flag OR close < close[1]) AND count(TrendState = -1, HigherBias = -1, StructureState = -1, MomentumDown, DownConfirm) >= minimum score AND NOT ShortLock[1]
Calculation: LongLock = (LongEntry OR LongLock[1]) AND NOT ShortEntry AND TrendState = 1 AND StructureState = 1
Calculation: ShortLock = (ShortEntry OR (ShortLock[1] AND NOT LongEntry)) AND TrendState = -1 AND StructureState = -1
Long: LongEntry
Short: ShortEntry
Long: NOT LongEntry AND TrendState = 1 AND StructureState = 1 AND UpConfirm AND Stretch < max stretch AND HigherBias != -1
Short: NOT ShortEntry AND TrendState = -1 AND StructureState = -1 AND DownConfirm AND Stretch > -max stretch AND HigherBias != 1
Long: ExtremeRecoverUp AND (BasisUp OR close crosses above Floor) AND HigherBias != -1 AND NOT LongEntry AND NOT ShortEntry
Short: ExtremeRecoverDown AND (BasisDown OR close crosses below Ceiling) AND HigherBias != 1 AND NOT ShortEntry AND NOT LongEntry
Long: UpBreak
Short: DownBreak