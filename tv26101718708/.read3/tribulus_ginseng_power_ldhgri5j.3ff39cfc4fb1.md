Calculation: GaussianKernelRegression(S) = sum over i = 0 to kernel window - 1 of close(S)[i] * exp(-i^2 / (2 * bandwidth^2)) divided by sum over the same i of exp(-i^2 / (2 * bandwidth^2))
Calculation: LowerBandBreak(S) = crossunder(close(S), GaussianKernelRegression(S) - band multiplier * SMA(abs(close(S) - GaussianKernelRegression(S)), deviation window))
Calculation: UpperBandBreak(S) = crossover(close(S), GaussianKernelRegression(S) + band multiplier * SMA(abs(close(S) - GaussianKernelRegression(S)), deviation window))
Calculation: BandSide(S) = 1 if LowerBandBreak(S), -1 if UpperBandBreak(S), otherwise BandSide(S)[1]
Calculation: RangeAvg(S, n) = ATR(n) if S is the chart, otherwise SMA(TrueRange(S), n)
Calculation: Slope(S) = RangeAvg(S, swing length) / swing length * slope multiplier if slope method is ATR; StDev(close(S), swing length) / swing length * slope multiplier if slope method is Stdev; abs(linear regression slope of close(S) against bar index over swing length) * slope multiplier / 2 if slope method is Linreg
Calculation: UTBotStop(S) = max(UTBotStop(S)[1], close(S) - d) if close(S) > UTBotStop(S)[1] and close(S)[1] > UTBotStop(S)[1]; min(UTBotStop(S)[1], close(S) + d) if close(S) < UTBotStop(S)[1] and close(S)[1] < UTBotStop(S)[1]; close(S) - d if close(S) > UTBotStop(S)[1]; otherwise close(S) + d; where d = UT Bot multiplier * RangeAvg(S, UT Bot period)
Calculation: UTBotPosition(S) = 1 if close(S) > UTBotStop(S)[1] and close(S)[1] <= UTBotStop(S)[1]; -1 if close(S) < UTBotStop(S)[1] and close(S)[1] >= UTBotStop(S)[1]; otherwise UTBotPosition(S)[1]
Calculation: SwingRollDirection(S) = 1 if close(S) > RollHigh and close(S)[1] <= RollHigh[1]; 0 if close(S) < RollLow and close(S)[1] >= RollLow[1]; otherwise SwingRollDirection(S)[1]; where RollHigh = highest(high(S), extended window) and RollLow = lowest(low(S), extended window) as of the latest swing roll, held until the next swing roll; a swing roll is a bar where Pattern holds and Pattern did not hold on any of the previous engulfing factor bars; Pattern = highest(high(S), engulfing factor) = highest(high(S), extended window) and lowest(low(S), engulfing factor) = lowest(low(S), extended window) and (lowest(low(S), extended window) = low(S)[engulfing factor - 1] or highest(high(S), extended window) = high(S)[engulfing factor - 1]); extended window is longer than engulfing factor
Calculation: PivotLineBreakUp(S) = 1 on the first bar after each confirmed pivot high of high(S) (swing length bars on each side) where close(S) > P - k * Q - swing length * Q, with P = that pivot high, Q = Slope(S) on its confirmation bar and k = bars since confirmation; otherwise 0
Calculation: PivotLineBreakDown(S) = 1 on the first bar after each confirmed pivot low of low(S) (swing length bars on each side) where close(S) < P + k * Q + swing length * Q, with P = that pivot low, Q = Slope(S) on its confirmation bar and k = bars since confirmation; otherwise 0
Calculation: Pair(X, Y, W) = for each bar, event X is processed if it occurs, then event Y is processed if it occurs; processing event E outputs 1 if the other event occurred on this bar or within the previous W bars and is pending (not yet paired), else 0; E becomes pending only when its output is 0; the other event is cleared; the bar's output is the output of the last event processed on that bar, or 0 if neither occurred
Calculation: ImpulseBar(S) = volume(S) > volume threshold and close(S) != EMA(close(S), EMA length) if S is the chart; TrueRange(S) > RangeAvg(S, swing length) otherwise
Calculation: BullSweep(S) = low(S) < lowest(low(S)[1], liquidity lookback) and close(S) > lowest(low(S)[1], liquidity lookback)
Calculation: BearSweep(S) = high(S) > highest(high(S)[1], liquidity lookback) and close(S) < highest(high(S)[1], liquidity lookback)
Calculation: LongRisk(S) = ((LowerBandBreak(S) and UTBotPosition(S) = 1) or (UTBotPosition(S) = 1 and UTBotPosition(S)[1] != 1 and BandSide(S) = 1)) and (liquidity confirmation disabled or barssince(BullSweep(S)) <= liquidity recency) and, for the chart only, (ADX filter disabled or ADX(ADX DI length, ADX smoothing) >= ADX threshold)
Calculation: ShortRisk(S) = ((UpperBandBreak(S) and UTBotPosition(S) = -1) or (UTBotPosition(S) = -1 and UTBotPosition(S)[1] != -1 and BandSide(S) = -1)) and (liquidity confirmation disabled or barssince(BearSweep(S)) <= liquidity recency) and, for the chart only, (ADX filter disabled or ADX(ADX DI length, ADX smoothing) >= ADX threshold)
Calculation: PrePhase(S) = 1 if ImpulseBar(S), otherwise MomentumPhase(S)[1]
Calculation: MomentumPhase(S) = 2 if PrePhase(S) = 1 and (LongRisk(S) or ShortRisk(S)); 0 if PrePhase(S) = 2 and (LongRisk(S) or ShortRisk(S)); otherwise PrePhase(S)
Calculation: BullMomentumHit(S) = (PrePhase(S) = 1 and ShortRisk(S)) or (PrePhase(S) = 2 and LongRisk(S))
Calculation: BearMomentumHit(S) = (PrePhase(S) = 1 and LongRisk(S) and not ShortRisk(S)) or (PrePhase(S) = 2 and ShortRisk(S) and not LongRisk(S))
Calculation: BullStructure(S) = Pair(SwingRollDirection(S) = 1 and SwingRollDirection(S)[1] != 1, PivotLineBreakUp(S), inner window)
Calculation: BearStructure(S) = Pair(SwingRollDirection(S) = 0 and SwingRollDirection(S)[1] != 0, PivotLineBreakDown(S), inner window)
Calculation: InversionLong(S) = Pair(BearMomentumHit(S), BearStructure(S), outer window); outer window is longer than inner window
Calculation: InversionShort(S) = Pair(BullMomentumHit(S), BullStructure(S), outer window)
Calculation: TotLongActive = barssince(InversionLong(total market cap)) <= macro memory
Calculation: TotShortActive = barssince(InversionShort(total market cap)) <= macro memory
Calculation: DomLongActive = barssince(InversionLong(BTC dominance)) <= macro memory
Calculation: DomShortActive = barssince(InversionShort(BTC dominance)) <= macro memory
Calculation: AlignBull = TotLongActive and DomLongActive
Calculation: AlignBear = TotShortActive and DomShortActive
Calculation: MACDHistogram(S) = MACD histogram(close(S), MACD fast, MACD slow, MACD signal)
Calculation: FinalLong = InversionLong(chart) and not (RSI filter enabled and lowest(RSI(close(chart), RSI length), RSI lookback) < RSI lower) and not (MACD filter enabled and MACDHistogram(chart) < 0 and MACDHistogram(chart) < MACDHistogram(chart)[1]) and not (ATR filter enabled and highest(max(open(chart) - close(chart), 0), ATR filter lookback) > ATR(ATR filter period) * body ratio)
Calculation: FinalShort = InversionShort(chart) and not (RSI filter enabled and highest(RSI(close(chart), RSI length), RSI lookback) > RSI upper) and not (MACD filter enabled and MACDHistogram(chart) > 0 and MACDHistogram(chart) > MACDHistogram(chart)[1]) and not (ATR filter enabled and highest(max(close(chart) - open(chart), 0), ATR filter lookback) > ATR(ATR filter period) * body ratio)
Long: FinalLong and not (TotLongActive and DomLongActive) and not (TotLongActive and DomShortActive)
Long: FinalLong and TotLongActive and DomLongActive
Long: FinalLong and TotLongActive and DomShortActive
Long: AlignBull and not AlignBull[1] and not FinalLong
Short: FinalShort and not (TotShortActive and DomShortActive) and not (TotShortActive and DomLongActive)
Short: FinalShort and TotShortActive and DomShortActive
Short: FinalShort and TotShortActive and DomLongActive
Short: AlignBear and not AlignBear[1] and not FinalShort