Calculation: Osc = MA(Stochastic %K(%K length), osc smoothing length, osc smoothing type)
Calculation: Trig = MA(Osc, trigger smoothing length, trigger smoothing type)
Calculation: SourceValue(X, source) = X on chart bars if MTF mode off or source is chart; if source is true MTF, X on T1 bars at the bar before the last completed T1 bar if confirmed MTF on, else at the forming T1 bar; if source is smooth MTF, EMA(X on T1 bars taken as for true MTF, smooth MTF length) on chart bars
Calculation: EntryOsc = SourceValue(Osc, entry source)
Calculation: EntryTrig = SourceValue(Trig, entry source)
Calculation: ShownOsc = SourceValue(Osc, display source)
Calculation: ShownTrig = SourceValue(Trig, display source)
Calculation: TrendMA = EMA(close, trend length)
Calculation: UpTrend = close > TrendMA AND TrendMA >= TrendMA[trend slope bars]
Calculation: DownTrend = close < TrendMA AND TrendMA <= TrendMA[trend slope bars]
Calculation: Rising = EntryOsc > EntryOsc[1] AND EntryTrig >= EntryTrig[1]
Calculation: Falling = EntryOsc < EntryOsc[1] AND EntryTrig <= EntryTrig[1]
Calculation: CrossUp = EntryOsc crosses above EntryTrig
Calculation: CrossDown = EntryOsc crosses below EntryTrig
Calculation: BodyFrac = abs(close - open) / (high - low)
Calculation: BullBar = close > open AND BodyFrac >= impulse min
Calculation: BearBar = close < open AND BodyFrac >= impulse min
Calculation: AdxStrength = min(1, max(0, (ADX(DI length, ADX smoothing length) - ADX base) / ADX range))
Calculation: ReversalLong = EntryOsc crosses above oversold level OR (EntryOsc was below oversold level on some bar from the current bar back through memory bars AND CrossUp AND EntryOsc > oversold level)
Calculation: ReversalShort = EntryOsc crosses below overbought level OR (EntryOsc was above overbought level on some bar from the current bar back through memory bars AND CrossDown AND EntryOsc < overbought level)
Calculation: LongScore = 100 * (extreme weight * (1 if ReversalLong, else deep-zone score if EntryOsc <= extreme low, else zone score if EntryOsc < oversold level, else neutral extreme score) + trend weight * (1 if UpTrend, else trend-off score if trend filter off, else trend-partial score if close > TrendMA, else 0) + slope weight * (1 if Rising, else slope-partial score if EntryOsc > EntryOsc[1], else 0) + ADX weight * AdxStrength + candle weight * (1 if BullBar, else candle-partial score if close > open, else 0) + cross weight * (1 if CrossUp, else cross-partial score if EntryOsc > EntryTrig, else 0)) / (extreme weight + trend weight + slope weight + ADX weight + candle weight + cross weight)
Calculation: ShortScore = 100 * (extreme weight * (1 if ReversalShort, else deep-zone score if EntryOsc >= extreme high, else zone score if EntryOsc > overbought level, else neutral extreme score) + trend weight * (1 if DownTrend, else trend-off score if trend filter off, else trend-partial score if close < TrendMA, else 0) + slope weight * (1 if Falling, else slope-partial score if EntryOsc < EntryOsc[1], else 0) + ADX weight * AdxStrength + candle weight * (1 if BearBar, else candle-partial score if close < open, else 0) + cross weight * (1 if CrossDown, else cross-partial score if EntryOsc < EntryTrig, else 0)) / (extreme weight + trend weight + slope weight + ADX weight + candle weight + cross weight)
Calculation: HtfState = HTF direction at the bar before the last completed T2 bar if confirmed HTF on, else at the forming T2 bar, where HTF direction = EMA direction if only HTF EMA check on, Williams direction if only HTF Williams check on, EMA direction if it equals Williams direction and 0 otherwise if both on; EMA direction = 1 if close > E AND E >= E[1], -1 if close < E AND E <= E[1], else 0, with E = EMA(close, HTF EMA length); Williams direction = 1 if Osc > Trig AND Osc > midline level, -1 if Osc < Trig AND Osc < midline level, else 0; Osc and Trig computed on T2 bars
Calculation: RawLong = ((reversal logic on AND ReversalLong) OR (continuation logic on AND (EntryOsc crosses above midline level OR (EntryOsc > midline level AND CrossUp)))) AND (cross gate off OR EntryOsc > EntryTrig) AND (slope gate off OR Rising) AND (trend gate off OR UpTrend) AND (midline gate off OR EntryOsc > midline level) AND (impulse gate off OR BullBar) AND LongScore >= score threshold
Calculation: RawShort = ((reversal logic on AND ReversalShort) OR (continuation logic on AND (EntryOsc crosses below midline level OR (EntryOsc < midline level AND CrossDown)))) AND (cross gate off OR EntryOsc < EntryTrig) AND (slope gate off OR Falling) AND (trend gate off OR DownTrend) AND (midline gate off OR EntryOsc < midline level) AND (impulse gate off OR BearBar) AND ShortScore >= score threshold
Long: RawLong AND NOT RawLong[1] AND (HTF filter off OR HtfState = 1 OR (neutral HTF allowed AND HtfState = 0)) AND bars since previous long entry >= cooldown bars AND (confirmed-only off OR current bar closed)
Short: RawShort AND NOT RawShort[1] AND (HTF filter off OR HtfState = -1 OR (neutral HTF allowed AND HtfState = 0)) AND bars since previous short entry >= cooldown bars AND (confirmed-only off OR current bar closed)
Long: ShownOsc >= ShownTrig
Short: ShownOsc < ShownTrig
Long: ShownOsc < oversold level OR (ShownOsc >= midline level AND ShownOsc <= overbought level)
Short: ShownOsc > overbought level OR (ShownOsc >= oversold level AND ShownOsc < midline level)
Long: LongScore >= score threshold
Short: ShortScore >= score threshold
Long: HTF filter on AND HtfState = 1
Short: HTF filter on AND HtfState = -1