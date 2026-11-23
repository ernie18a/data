Calculation: Volatility(X, n) = ATR(X, n) if X is the traded instrument, otherwise SMA(TR(X), n)
Calculation: Pump(X) = volume(X) > volume threshold and close(X) != EMA(close(X), EMA period) if X is the traded instrument, otherwise TR(X) > Volatility(X, pivot length)
Calculation: Gate(X) = ADX filter disabled or ADX(X, DI length, ADX smoothing) >= ADX threshold if X is the traded instrument, otherwise true
Calculation: KernelAvg(s) = (sum over i from 0 to kernel length - 1 of s[i] * exp(-i^2 / (2 * kernel bandwidth^2))) / (sum over the same i of exp(-i^2 / (2 * kernel bandwidth^2)))
Calculation: LowerCross(X) = crossunder(close(X), KernelAvg(close(X)) - band multiplier * SMA(abs(close(X) - KernelAvg(close(X))), band window))
Calculation: UpperCross(X) = crossover(close(X), KernelAvg(close(X)) + band multiplier * SMA(abs(close(X) - KernelAvg(close(X))), band window))
Calculation: LastBand(X) = 1 if LowerCross(X), -1 if UpperCross(X), otherwise LastBand(X)[1]
Calculation: UTPos(X) = 1 if close(X) > s[1] and close(X)[1] <= s[1]; -1 if close(X) < s[1] and close(X)[1] >= s[1]; otherwise UTPos(X)[1]; where s = UTBotStop(close(X), UT multiplier * Volatility(X, UT period))
Calculation: LiqLow(X) = low(X) < lowest(low(X)[1], liquidity lookback) and close(X) > lowest(low(X)[1], liquidity lookback)
Calculation: LiqHigh(X) = high(X) > highest(high(X)[1], liquidity lookback) and close(X) < highest(high(X)[1], liquidity lookback)
Calculation: RevL(X) = ((LowerCross(X) and UTPos(X) = 1) or (UTPos(X) = 1 and UTPos(X)[1] != 1 and LastBand(X) = 1)) and (AFY filter disabled or BarsSince(LiqLow(X)) <= AFY window) and Gate(X)
Calculation: RevS(X) = ((UpperCross(X) and UTPos(X) = -1) or (UTPos(X) = -1 and UTPos(X)[1] != -1 and LastBand(X) = -1)) and (AFY filter disabled or BarsSince(LiqHigh(X)) <= AFY window) and Gate(X)
Calculation: PhasePre(X) = 1 if Pump(X), otherwise Phase(X)[1]
Calculation: Phase(X) = 2 if PhasePre(X) = 1 and (RevS(X) or RevL(X)); 0 if PhasePre(X) = 2 and (RevS(X) or RevL(X)); otherwise PhasePre(X)
Calculation: MhB(X) = (PhasePre(X) = 1 and RevS(X)) or (PhasePre(X) = 2 and RevL(X))
Calculation: MhS(X) = (PhasePre(X) = 1 and RevL(X) and not RevS(X)) or (PhasePre(X) = 2 and RevS(X) and not RevL(X))
Calculation: Slope(X) = Volatility(X, pivot length) / pivot length * slope multiplier if slope method is ATR; STDEV(close(X), pivot length) / pivot length * slope multiplier if slope method is Stdev; abs(linear regression slope of close(X) against bar index over pivot length) / 2 * slope multiplier if slope method is Linreg
Calculation: LocalUp(X) = UpOn(X) = 1 and UpOn(X)[1] = 0, where UpOn(X) = 0 on bars where PivotHigh(high(X), pivot length, pivot length) is confirmed, otherwise 1 if close(X) > UpLine(X) - UpSlope(X) * pivot length, otherwise UpOn(X)[1]; UpLine(X) = the confirmed pivot high on those bars, otherwise UpLine(X)[1] - UpSlope(X); UpSlope(X) = Slope(X) on those bars, otherwise UpSlope(X)[1]
Calculation: LocalDown(X) = DnOn(X) = 1 and DnOn(X)[1] = 0, where DnOn(X) = 0 on bars where PivotLow(low(X), pivot length, pivot length) is confirmed, otherwise 1 if close(X) < DnLine(X) + DnSlope(X) * pivot length, otherwise DnOn(X)[1]; DnLine(X) = the confirmed pivot low on those bars, otherwise DnLine(X)[1] + DnSlope(X); DnSlope(X) = Slope(X) on those bars, otherwise DnSlope(X)[1]
Calculation: SwingValid(X) = (lowest(low(X), swing factor) = lowest(low(X), twice swing factor)) and (highest(high(X), swing factor) = highest(high(X), twice swing factor)) and (lowest(low(X), twice swing factor) = low(X)[swing factor - 1] or highest(high(X), twice swing factor) = high(X)[swing factor - 1])
Calculation: Swing(X) = SwingValid(X) and BarsSince(SwingValid(X)[1]) >= swing factor
Calculation: StructDir(X) = 1 if crossover(close(X), RangeHi(X)), 0 if crossunder(close(X), RangeLo(X)), otherwise StructDir(X)[1]; RangeHi(X) = highest(high(X), twice swing factor) and RangeLo(X) = lowest(low(X), twice swing factor), each re-taken on bars where Swing(X) starts (Swing(X) and not Swing(X)[1]) and held otherwise
Calculation: Pair(A, B, W) = output, where each bar: if A-pending or B-pending then age = age + 1, and if age > W then A-pending = false, B-pending = false, age = 0; output = false; if A occurs then output = B-pending, A-pending = not output, B-pending = false, age = 0; if B occurs then output = A-pending, B-pending = not output, A-pending = false, age = 0
Calculation: InvUp(X) = Pair(MhS(X), Pair(StructDir(X) = 0 and StructDir(X)[1] = 1, LocalDown(X), pair window), inversion window)
Calculation: InvDn(X) = Pair(MhB(X), Pair(StructDir(X) = 1 and StructDir(X)[1] != 1, LocalUp(X), pair window), inversion window)
Calculation: Recent(E) = BarsSince(E) <= macro window
Calculation: MacroBull = Recent(InvUp(total crypto market cap)) and Recent(InvUp(BTC dominance))
Calculation: MacroBear = Recent(InvDn(total crypto market cap)) and Recent(InvDn(BTC dominance))
Calculation: MACDhist(X) = histogram of MACD(close(X), MACD fast length, MACD slow length, MACD signal length)
Calculation: LongBlocked = (RSI filter enabled and lowest(RSI(close(traded instrument), RSI period), RSI lookback) < RSI lower bound) or (MACD filter enabled and MACDhist(traded instrument) < 0 and MACDhist(traded instrument) < MACDhist(traded instrument)[1]) or (ATR filter enabled and highest(abs(close(traded instrument) - open(traded instrument)) if close(traded instrument) < open(traded instrument), otherwise 0, ATR filter lookback) > ATR(traded instrument, ATR filter period) * body ratio)
Calculation: ShortBlocked = (RSI filter enabled and highest(RSI(close(traded instrument), RSI period), RSI lookback) > RSI upper bound) or (MACD filter enabled and MACDhist(traded instrument) > 0 and MACDhist(traded instrument) > MACDhist(traded instrument)[1]) or (ATR filter enabled and highest(abs(close(traded instrument) - open(traded instrument)) if close(traded instrument) > open(traded instrument), otherwise 0, ATR filter lookback) > ATR(traded instrument, ATR filter period) * body ratio)
Long: InvUp(traded instrument) and not LongBlocked and not (Recent(InvUp(total crypto market cap)) and (Recent(InvUp(BTC dominance)) or Recent(InvDn(BTC dominance))))
Long: InvUp(traded instrument) and not LongBlocked and MacroBull
Long: InvUp(traded instrument) and not LongBlocked and Recent(InvUp(total crypto market cap)) and Recent(InvDn(BTC dominance))
Long: MacroBull and not MacroBull[1] and not (InvUp(traded instrument) and not LongBlocked)
Short: InvDn(traded instrument) and not ShortBlocked and not (Recent(InvDn(total crypto market cap)) and (Recent(InvDn(BTC dominance)) or Recent(InvUp(BTC dominance))))
Short: InvDn(traded instrument) and not ShortBlocked and MacroBear
Short: InvDn(traded instrument) and not ShortBlocked and Recent(InvDn(total crypto market cap)) and Recent(InvUp(BTC dominance))
Short: MacroBear and not MacroBear[1] and not (InvDn(traded instrument) and not ShortBlocked)