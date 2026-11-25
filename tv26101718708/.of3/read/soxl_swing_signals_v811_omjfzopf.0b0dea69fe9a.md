Calculation: SlowK = Slow Stochastic %K(close, high, low, stochastic lookback, stochastic smoothing)
Calculation: MACDH = MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback)
Calculation: BBPctShort = Bollinger %B(close, short window, band multiplier)
Calculation: BBPctLong = Bollinger %B(close, long window, band multiplier), where long window > short window
Calculation: RegPctShort = (close - C + m*S) / (2*m*S), where C = LinReg(close, short window, 0), S = StdDev(close - C, short window), m = regression multiplier
Calculation: RegPctLong = (close - C + m*S) / (2*m*S), where C = LinReg(close, long window, 0), S = StdDev(close - C, long window), m = regression multiplier, long window > short window
Calculation: RegSlopeLong = (LinReg(close, long window, 0) - LinReg(close, long window, 1)) / LinReg(close, long window, 0)
Calculation: PctDist(n) = (close - SMA(close, n)) / SMA(close, n), with short SMA < mid SMA < long SMA
Calculation: UptrendRegime = SMA(close, mid SMA) > SMA(close, long SMA)
Calculation: RegimeDistOK = (UptrendRegime AND PctDist(mid SMA) >= bull mid distance min) OR (NOT UptrendRegime AND PctDist(long SMA) <= bear long distance max)
Calculation: CrashLock = Highest(broad-market implied volatility, crash lookback) >= crash level
Calculation: Drawdown = (close - Highest(close, drawdown lookback)) / Highest(close, drawdown lookback)
Calculation: LowerBandTouch = RegPctLong <= long regression lower level OR BBPctLong <= long BB lower level OR RegPctShort <= short regression lower level OR BBPctShort <= short BB lower level
Calculation: VolPanic = Highest(broad-market implied volatility, panic lookback) / SMA(broad-market implied volatility, panic SMA lookback)
Calculation: AnchLoPct = (close - F + a*R) / (2*a*R), where F = linear regression fitted value at the current bar over the last N closes, R = population standard deviation of those closes' residuals from that fit, a = anchored multiplier, N = bars from the last confirmed pivot low through the current bar clamped to [anchored min bars, anchored max bars], and a pivot low is a bar whose low is the lowest of the pivot left bars before it and the pivot right bars after it
Calculation: AnchHiPct = AnchLoPct with the last confirmed pivot high in place of the pivot low, where a pivot high is a bar whose high is the highest of the pivot left bars before it and the pivot right bars after it
Calculation: FibRetrace = (H - close) / (H - L), where H = Highest(high, swing high lookback) and L = Lowest(low, prior low lookback) over the prior low lookback bars counted back from H's bar, including that bar
Calculation: FibNear(level) = ABS(FibRetrace - level) < fib tolerance
Calculation: LongFactors = count of true among: VolPanic >= conviction panic level; (RegPctLong <= band factor level AND BBPctLong <= band factor level); MACDH > MACDH[1]; broad-market implied volatility >= conviction vol level; RegSlopeLong > conviction slope level; AnchLoPct <= anchored band level; (FibNear(fib level A) OR FibNear(fib level B))
Calculation: ShortFactors = count of true among: SlowK >= short SlowK factor level; (RegPctShort >= short band factor level AND BBPctShort >= short band factor level); MACDH - MACDH[1] <= short MACD factor level; broad-market implied volatility < calm volatility level; PctDist(mid SMA) > extension level; AnchHiPct >= anchored high band level; SectorDistribution
Calculation: SectorDistribution = (-phase slope threshold <= SectorSlope <= phase slope threshold) AND ((sector index close - Lowest(sector index close, range lookback)) / (Highest(sector index close, range lookback) - Lowest(sector index close, range lookback)) >= range split level), where SectorSlope = 100 * ROC(SMA(sector index close, phase SMA lookback), phase slope bars)
Calculation: LongGate = LongFactors >= conviction gate AND bars since last Long entry >= long cooldown
Calculation: ShortGate = bars since last Short entry >= short cooldown
Calculation: LongTrigger = (SlowK <= capitulation SlowK max AND broad-market implied volatility >= capitulation vol min AND VolPanic >= capitulation panic min AND broad-market implied volatility <= broad-market implied volatility[1] * capitulation vol ratio AND LowerBandTouch) OR (SlowK <= oversold SlowK max AND PctDist(short SMA) <= oversold dist max AND broad-market implied volatility >= oversold vol min AND LowerBandTouch AND MACDH > MACDH[1]) OR (RegSlopeLong > pullback slope min AND RegPctLong <= pullback long regression max AND RegPctShort <= pullback short regression max AND PctDist(short SMA) <= 0 AND SlowK <= pullback SlowK max AND UptrendRegime AND ROC(close, 1) > pullback day-drop limit AND close > close[1]) OR (BBPctShort <= 0 AND PctDist(short SMA) <= band dump dist max AND SlowK <= band dump SlowK max AND broad-market implied volatility >= oversold vol min AND MACDH > MACDH[1]) OR (broad-market implied volatility >= peak vol min AND broad-market implied volatility <= Highest(broad-market implied volatility, peak lookback) * peak vol ratio AND PctDist(short SMA) <= peak dist max AND SlowK <= peak SlowK max AND LowerBandTouch) OR (SlowK <= deep SlowK max AND PctDist(short SMA) <= deep dist max AND broad-market implied volatility >= deep vol min AND VolPanic >= deep panic min AND MACDH > MACDH[1]) OR (ROC(close, 1) <= waterfall day-drop max AND broad-market implied volatility >= waterfall vol min AND SlowK <= waterfall SlowK max AND LowerBandTouch)
Calculation: ShortTrigger = (PctDist(short SMA) >= blowoff dist min AND PctDist(mid SMA) < blowoff mid dist max AND RegimeDistOK AND SlowK >= blowoff SlowK min AND (BBPctShort >= tight upper level OR RegPctShort >= tight upper level) AND broad-market implied volatility < short vol max AND (PlusDI(DI lookback) - MinusDI(DI lookback)) < DI gap max AND MACDH > 0 AND NOT CrashLock AND Drawdown <= drawdown threshold) OR (BBPctShort >= BB breakout level AND PctDist(short SMA) >= BB breakout dist min AND SlowK >= BB breakout SlowK min AND RegimeDistOK AND broad-market implied volatility < short vol max AND NOT CrashLock AND Drawdown <= drawdown threshold) OR (close > close[divergence lookback] AND RSI(RSI lookback) < RSI(RSI lookback)[divergence lookback] AND PctDist(short SMA) >= divergence dist min AND RSI(RSI lookback) >= divergence RSI min AND broad-market implied volatility < divergence vol max AND NOT CrashLock AND UptrendRegime AND Drawdown <= drawdown threshold) OR (close >= SMA(close, short SMA) on each of the rollover min bars ending at the prior bar AND SlowK[1] >= rollover prior SlowK min AND SlowK < SlowK[1] AND PctDist(short SMA) >= rollover dist min AND broad-market implied volatility < short vol max AND NOT CrashLock AND UptrendRegime AND Drawdown <= drawdown threshold) OR (ROC(broad-market implied volatility, vol change lookback) >= vol change min AND PctDist(short SMA) >= vol rise dist min AND SlowK >= vol rise SlowK min AND broad-market implied volatility < vol rise vol max AND NOT CrashLock AND UptrendRegime) OR (ROC(SMA(sector index close, sector long SMA), bear slope bars) <= bear slope threshold AND close < SMA(close, mid SMA) AND close <= Lowest(close, new-low lookback)[1] AND SlowK >= bear SlowK min AND NOT CrashLock) OR (BBPctShort >= top-fade BB min AND SlowK >= top-fade SlowK min AND PctDist(short SMA) >= top-fade dist min AND ROC(close, 1) < stall day-change max AND close < close[1] AND NOT CrashLock)
Calculation: ShortZone = PctDist(short SMA) >= zone dist min AND (BBPctShort >= zone BB upper level OR RegPctShort >= zone regression upper level OR RegPctLong >= zone regression upper level) AND broad-market implied volatility < short vol max AND NOT CrashLock AND RegimeDistOK
Calculation: LongZone = LowerBandTouch AND (SlowK <= zone SlowK max OR (RegSlopeLong > zone slope level AND PctDist(short SMA) <= 0))
Calculation: TermRatio = 9-day broad-market implied volatility / broad-market implied volatility
Long: LongTrigger AND LongGate
Long: (ROC(close, 1) <= waterfall day-drop max AND broad-market implied volatility >= waterfall vol min AND SlowK <= waterfall SlowK max AND LowerBandTouch) AND LongGate
Long: LongTrigger AND LongGate AND LongFactors >= long high conviction level
Long: LongZone
Long: LongZone AND NOT (LongTrigger AND LongGate)
Long: AnchLoPct <= anchored band level AND AnchLoPct[1] > anchored band level
Long: FibNear(fib level A) AND NOT FibNear(fib level A)[1]
Long: FibNear(fib level B) AND NOT FibNear(fib level B)[1]
Long: TermRatio >= backwardation level AND TermRatio[1] < backwardation level
Short: ShortTrigger AND ShortGate
Short: ShortTrigger AND ShortGate AND ShortFactors >= short high conviction level
Short: ShortZone
Short: ShortZone AND NOT (ShortTrigger AND ShortGate)
Short: AnchHiPct >= anchored high band level AND AnchHiPct[1] < anchored high band level
Short: SectorDistribution AND NOT SectorDistribution[1]
Option: buy call, LongTrigger AND LongGate
Option: buy put, ShortTrigger AND ShortGate
Exit: long, bars since entry >= long hold bars
Exit: short, bars since entry >= bear-cycle hold bars AND position was opened by the bear-cycle condition
Exit: short, bars since entry >= top-fade hold bars AND position was opened by the top-fade condition