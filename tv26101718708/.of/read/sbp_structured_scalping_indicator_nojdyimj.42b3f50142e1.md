Calculation: Session = bars since the start of the current higher-timeframe period (the chart's own bars, reset at each new period, count capped at a maximum)
Calculation: Profile = volume-by-price histogram over Session bars: split the Session low-to-high range into equal price rows; each bar's volume is spread across the rows its high-low range overlaps, proportional to overlap
Calculation: Control = midpoint of the highest-volume row of Profile
Calculation: CoreLower, CoreUpper = lower and upper edges of the contiguous row block grown from the Control row until it holds a set fraction of total Profile volume; each step adds the neighbouring row with more volume (the upper row if it is larger or the lower side is exhausted, otherwise the lower row). Recomputed on every bar
Calculation: ValueCenter = (CoreUpper+CoreLower)/2; ValueWidth = CoreUpper-CoreLower
Calculation: FastEMA, SlowEMA = EMA of close, FastEMA length shorter than SlowEMA length
Calculation: ATR = Average True Range on chart bars
Calculation: Body = |close-open|; UpperWick = high-max(open,close); LowerWick = min(open,close)-low; CloseLoc = (close-low)/(high-low)
Calculation: RelVol = volume / EMA(volume, long length)
Calculation: Pressure = EMA(short length) of (SignedVol / EMA(volume, long length)), SignedVol = +volume if close>open, -volume if close<open, else 0; PressureChg = Pressure - Pressure[1]
Calculation: Momentum = EMA(short length) of (close - close[1]) / ATR
Calculation: PriorHigh, PriorLow = highest high / lowest low of the previous N bars, excluding the current bar
Calculation: AdaptCenter = Kaufman-adaptive moving average of hlc3: Eff = |close-close[n]| / sum of |close change| over n bars (0 if the sum is 0); alpha = (Eff*(fastConst-slowConst)+slowConst)^2; AdaptCenter = prev + alpha*(hlc3-prev), initialised at hlc3; Slope = AdaptCenter - AdaptCenter[2]
Calculation: BullTrend = FastEMA>SlowEMA AND close>=AdaptCenter AND Slope>=0; BearTrend = FastEMA<SlowEMA AND close<=AdaptCenter AND Slope<=0
Calculation: Tol = max(small fraction of ATR, small fraction of ValueWidth)
Calculation: Bull setups: CoreRej = low<=CoreLower+Tol AND close>CoreLower AND LowerWick>=k*max(Body,minimal tick) AND CloseLoc>=upper-mid threshold; ControlReclaim = low<=Control AND close>Control AND close>open AND PressureChg>0; Sweep = low<PriorLow AND close>PriorLow AND CloseLoc>=upper-mid threshold; Acceptance = close>CoreUpper AND close[1]<=CoreUpper[1] AND CloseLoc>=high threshold; Initiative = RelVol>=threshold AND close>open AND Body>=fraction*ATR AND CloseLoc>=highest threshold
Calculation: Bear setups = exact mirror of Bull setups (CoreRej uses high>=CoreUpper-Tol, close<CoreUpper, UpperWick, CloseLoc<=1-threshold; ControlReclaim uses high>=Control, close<Control, close<open, PressureChg<0; Sweep uses high>PriorHigh, close<PriorHigh; Acceptance uses close<CoreLower, close[1]>=CoreLower[1]; Initiative uses close<open; every CloseLoc threshold t becomes 1-t)
Calculation: Trigger = any one of the five setups of that side is true
Calculation: BullLocation = close>=ValueCenter OR Bull CoreRej OR Bull ControlReclaim OR Bull Sweep; BearLocation = close<=ValueCenter OR Bear CoreRej OR Bear ControlReclaim OR Bear Sweep
Calculation: BullEvidence = count of true among: BullTrend, Pressure>0, PressureChg>0, Momentum>0, BullLocation, CloseLoc>=mid threshold; BearEvidence = mirror (BearTrend, Pressure<0, PressureChg<0, Momentum<0, BearLocation, CloseLoc<=1-mid threshold)
Calculation: BullScore = sum of fixed positive weights for each true item: BullTrend, Pressure>0, PressureChg>0, Momentum>0, Bull CoreRej, Bull ControlReclaim, Bull Sweep, Bull Acceptance, Bull Initiative; BearScore = mirror with the Bear items and the same weights
Calculation: StrongBullOpposition = BearTrend AND Pressure<-threshold AND Momentum<0; StrongBearOpposition = BullTrend AND Pressure>threshold AND Momentum>0
Calculation: LastSignal = direction of the most recent Long or Short signal emitted (none initially)
Long: bar is completed AND Bull Trigger AND BullEvidence>=minimum count AND BullScore>=minimum score AND BullScore>=BearScore+minimum margin AND NOT StrongBullOpposition AND LastSignal is not Long
Short: bar is completed AND Bear Trigger AND BearEvidence>=minimum count AND BearScore>=minimum score AND BearScore>=BullScore+minimum margin AND NOT StrongBearOpposition AND LastSignal is not Short