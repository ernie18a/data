Calculation: CLV = (2 * close - low - high) / max(high - low, minimum tick)
Calculation: Standardize(x, n) = (x - SMA(x, n)) / STDEV(x, n), or 0 if STDEV(x, n) is 0
Calculation: Smooth(x, n) = moving average of the smoothing type: ALMA(x, n, ALMA offset, ALMA sigma), EMA(x, n), SMA(x, n), RMA(x, n), or WMA(x, n)
Calculation: Accum = CUM(CLV * volume * (1 + ABS(CLV)) * (volume boost if volume > SMA(volume, baseline length), else 1))
Calculation: PressureScore = Standardize(Accum - Smooth(Accum, flow smoothing length), normalization length)
Calculation: EffortScore = Standardize(EMA(CLV * RelVol, effort length), normalization length), where RelVol = volume / SMA(volume, baseline length) if that SMA is above 0, else 1
Calculation: SigmaScore = Standardize(SQRT(EMA(R ^ 2, sigma length)), normalization length), where R = LN(volume / volume[1]) if volume > 0 and volume[1] > 0, else 0
Calculation: MomentumScore = (RSI(close, RSI length) - 50) / momentum scale
Calculation: EfficiencyScore = (close - close[efficiency length]) / SUM(ABS(close - close[1]), efficiency length), or 0 if that SUM is 0
Calculation: VwapScore = (close - VWAP(hlc3)) / ATR(ATR length), or 0 if ATR(ATR length) is 0
Calculation: Flow = pressure weight * PressureScore + effort weight * EffortScore + sigma weight * SigmaScore + momentum weight * MomentumScore + efficiency weight * EfficiencyScore + VWAP weight * VwapScore
Calculation: FlowGap = Flow - EMA(Flow, signal length)
Calculation: UpperEnv(m) = EMA(Flow, envelope length) + m * STDEV(Flow, envelope length)
Calculation: LowerEnv(m) = EMA(Flow, envelope length) - m * STDEV(Flow, envelope length)
Calculation: PriorPivotLowOffset = most recent i in [pivot length + 1, scan length] where PivotLow(Flow, pivot length, pivot length)[i] is not NA
Calculation: PriorPivotLow = PivotLow(Flow, pivot length, pivot length)[PriorPivotLowOffset]
Calculation: PriorPivotHighOffset = most recent i in [pivot length + 1, scan length] where PivotHigh(Flow, pivot length, pivot length)[i] is not NA
Calculation: PriorPivotHigh = PivotHigh(Flow, pivot length, pivot length)[PriorPivotHighOffset]
Long: Flow > UpperEnv(envelope multiplier) AND Flow > 0 AND FlowGap > minimum spread AND PressureScore > 0 AND EffortScore > 0 AND (not trend gate OR (EMA(close, shorter trend length) >= EMA(close, longer trend length) AND close >= EMA(close, longer trend length))) AND (not VWAP gate OR close >= VWAP(hlc3))
Long: Flow > UpperEnv(extreme multiplier) AND Flow > 0 AND FlowGap > minimum spread AND PressureScore > 0 AND EffortScore > 0 AND (not trend gate OR (EMA(close, shorter trend length) >= EMA(close, longer trend length) AND close >= EMA(close, longer trend length))) AND (not VWAP gate OR close >= VWAP(hlc3))
Long: Flow > EMA(Flow, envelope length) AND FlowGap > 0 AND PressureScore + EffortScore + VwapScore > 0
Long: PivotLow(Flow, pivot length, pivot length) > PriorPivotLow AND low[pivot length] < low[pivot length + PriorPivotLowOffset]
Short: Flow < LowerEnv(envelope multiplier) AND Flow < 0 AND FlowGap < -minimum spread AND PressureScore < 0 AND EffortScore < 0 AND (not trend gate OR (EMA(close, shorter trend length) < EMA(close, longer trend length) AND close < EMA(close, longer trend length))) AND (not VWAP gate OR close < VWAP(hlc3))
Short: Flow < LowerEnv(extreme multiplier) AND Flow < 0 AND FlowGap < -minimum spread AND PressureScore < 0 AND EffortScore < 0 AND (not trend gate OR (EMA(close, shorter trend length) < EMA(close, longer trend length) AND close < EMA(close, longer trend length))) AND (not VWAP gate OR close < VWAP(hlc3))
Short: Flow < EMA(Flow, envelope length) AND FlowGap < 0 AND PressureScore + EffortScore + VwapScore < 0
Short: PivotHigh(Flow, pivot length, pivot length) < PriorPivotHigh AND high[pivot length] > high[pivot length + PriorPivotHighOffset]
Exit: long, PressureScore > 0 AND EffortScore < 0 AND Flow > 0 AND FlowGap < 0
Exit: short, PressureScore < 0 AND EffortScore > 0 AND Flow < 0 AND FlowGap > 0