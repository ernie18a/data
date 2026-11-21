Calculation: SmoothEff = EMA(Kaufman efficiency ratio(range source, efficiency lookback), efficiency smoothing lookback)
Calculation: ConfirmBars = max(base confirm bars + low-ER confirm add, low-ER confirm floor) if SmoothEff < ER threshold 1; else base confirm bars + mid-ER confirm add if SmoothEff < ER threshold 3; else base confirm bars if SmoothEff < ER threshold 4; else max(base confirm bars - high-ER confirm reduce, high-ER confirm floor)
Calculation: RangeMult = range multiplier * (low-ER range factor if SmoothEff < ER threshold 2; else high-ER range factor if SmoothEff > ER threshold 5; else 1)
Calculation: RangeBuffer = ATR(range lookback) * RangeMult
Calculation: RangeLine = range source - RangeBuffer if range source > RangeLine[1] + RangeBuffer; else range source + RangeBuffer if range source < RangeLine[1] - RangeBuffer; else RangeLine[1]
Calculation: TrendSign = 1 if RangeLine > RangeLine[1]; else -1 if RangeLine < RangeLine[1]; else TrendSign[1]
Calculation: RegimeState = TrendSign if TrendSign != RegimeState[1] on each of the ConfirmBars bars ending with this bar, all after the last change of RegimeState; else RegimeState[1]
Calculation: HTFSide = 1 if close(T2, last completed bar) > EMA(close, HTF EMA lookback, T2, last completed bar); else -1
Calculation: EnvOpen = (ADX(ADX lookback) >= ADX floor OR Choppiness index(chop lookback) <= chop ceiling OR HTFSide = RegimeState OR aggressive entries enabled) AND (HTF gate disabled OR HTFSide = RegimeState)
Calculation: T1Pivot = Classic pivot point(T1, last completed bar)
Calculation: ShortEMA = EMA(close, short EMA lookback)
Calculation: MidEMA = EMA(close, mid EMA lookback)
Calculation: MeanBasis = EMA(close, reversion lookback)
Calculation: WeaveAvg = (ShortEMA + MidEMA + EMA(close, long EMA lookback)) / 3
Calculation: WeaveSign = 1 if close > T1Pivot AND ShortEMA > MidEMA AND WeaveAvg > WeaveAvg[weave slope lookback]; else -1 if close < T1Pivot AND ShortEMA < MidEMA AND WeaveAvg < WeaveAvg[weave slope lookback]; else 0
Calculation: SwingHigh = value of the most recent Pivot high(high, swing length, swing length)
Calculation: SwingLow = value of the most recent Pivot low(low, swing length, swing length)
Calculation: PivotTrend = 1 if the two most recent Pivot low values exist and the latest exceeds the previous; else -1 if the two most recent Pivot high values exist and the latest is below the previous; else 0
Calculation: BullGap = low > high[2]
Calculation: BearGap = high < low[2]
Calculation: Displaced = displacement requirement disabled OR abs(close - open) >= ATR(range lookback) * displacement factor
Calculation: BullCont = continuation enabled AND RegimeState = 1 AND close crosses above RangeLine AND close > T1Pivot AND close > MeanBasis
Calculation: BearCont = continuation enabled AND RegimeState = -1 AND close crosses below RangeLine AND close < T1Pivot AND close < MeanBasis
Calculation: BullRot = aggressive entries enabled AND (RegimeState = 1 OR close > RangeLine) AND (close crosses above T1Pivot OR close crosses above MeanBasis OR close crosses above ShortEMA)
Calculation: BearRot = aggressive entries enabled AND (RegimeState = -1 OR close < RangeLine) AND (close crosses below T1Pivot OR close crosses below MeanBasis OR close crosses below ShortEMA)
Calculation: BullDivergenceBlock = a bullish divergence pivot at bar p, confirmed by this bar, with bars since p <= divergence block bars, where a bullish divergence pivot at p is a Pivot low(low, divergence pivot length, divergence pivot length) at p such that low(p) < low of the previous Pivot low(...), RSI(close, RSI lookback) at p > RSI at that previous pivot, and p - previous pivot bar <= divergence window
Calculation: BearDivergenceBlock = a bearish divergence pivot at bar p, confirmed by this bar, with bars since p <= divergence block bars, where a bearish divergence pivot at p is a Pivot high(high, divergence pivot length, divergence pivot length) at p such that high(p) > high of the previous Pivot high(...), RSI(close, RSI lookback) at p < RSI at that previous pivot, and p - previous pivot bar <= divergence window
Calculation: LongStopLevel = min(SwingLow, close - stop ATR multiple * ATR(range lookback)) if SwingLow exists; else close - stop ATR multiple * ATR(range lookback)
Calculation: ShortStopLevel = max(SwingHigh, close + stop ATR multiple * ATR(range lookback)) if SwingHigh exists; else close + stop ATR multiple * ATR(range lookback)
Calculation: LongRiskUnit = max(entry price - LongStopLevel, minimum price increment)
Calculation: ShortRiskUnit = max(ShortStopLevel - entry price, minimum price increment)
Calculation: LongTakeProfit = entry price + reward multiple * LongRiskUnit
Calculation: ShortTakeProfit = entry price - reward multiple * ShortRiskUnit
Calculation: LongStopActive = max(LongStopLevel, close - trail ATR multiple * ATR(range lookback)) if high >= entry price + trail start multiple * LongRiskUnit; else LongStopLevel
Calculation: ShortStopActive = min(ShortStopLevel, close + trail ATR multiple * ATR(range lookback)) if low <= entry price - trail start multiple * ShortRiskUnit; else ShortStopLevel
Long: position side is not long AND (RegimeState = 1 OR close > RangeLine OR ShortEMA > MidEMA) AND EnvOpen AND ((close > SwingHigh AND close[1] <= SwingHigh AND Displaced AND BullGap within the last FVG window bars) OR BullCont OR BullRot) AND (reclaim requirement disabled OR (low < MeanBasis AND close > MeanBasis) OR BullCont OR BullRot) AND (WeaveSign >= 0 OR PivotTrend >= 0 OR close > RangeLine OR close > T1Pivot) AND (divergence block disabled OR NOT BearDivergenceBlock)
Short: position side is not short AND (RegimeState = -1 OR close < RangeLine OR ShortEMA < MidEMA) AND EnvOpen AND ((close < SwingLow AND close[1] >= SwingLow AND Displaced AND BearGap within the last FVG window bars) OR BearCont OR BearRot) AND (reclaim requirement disabled OR (high > MeanBasis AND close < MeanBasis) OR BearCont OR BearRot) AND (WeaveSign <= 0 OR PivotTrend <= 0 OR close < RangeLine OR close < T1Pivot) AND (divergence block disabled OR NOT BullDivergenceBlock)
Exit: long, low <= LongStopActive OR high >= LongTakeProfit OR RegimeState = -1 OR WeaveSign = -1
Exit: short, high >= ShortStopActive OR low <= ShortTakeProfit OR RegimeState = 1 OR WeaveSign = 1