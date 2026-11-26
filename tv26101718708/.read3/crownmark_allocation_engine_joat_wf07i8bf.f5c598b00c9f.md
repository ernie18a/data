Calculation: MACD = EMA(close, fast lookback) - EMA(close, slow lookback)
Calculation: LinRegSlope(x, n) = LinReg(x, n, 0) - LinReg(x, n, 1)
Calculation: ZScore(x, n) = (x - SMA(x, n)) / STDEV(x, n) if STDEV(x, n) > 0 else 0
Calculation: RangePosition(x, n) = 2 * (x - LOWEST(x, n)) / (HIGHEST(x, n) - LOWEST(x, n)) - 1 if HIGHEST(x, n) > LOWEST(x, n) else 0
Calculation: VolatilityExpansion(n) = STDEV(close, n) / SMA(close, n)
Calculation: Directional regime = RangePosition(MACD, slow lookback) * trend weight + clamp(ZScore(LinRegSlope(MACD, fast lookback), volatility lookback), -z-score limit, z-score limit) * slope weight + clamp((ADX(ADX lookback) - ADX center) / ADX scale, -1, 1) * strength weight * sign(MACD) + (2 * EfficiencyRatio(close, efficiency lookback) - 1) * efficiency weight * sign(MACD) + clamp(ZScore(VolatilityExpansion(volatility lookback), volatility lookback), -z-score limit, z-score limit) * volatility weight * sign(MACD)
Calculation: Adaptive baseline = KAMA(close, baseline lookback, fast smoothing lookback, slow smoothing lookback)
Calculation: Hybrid width = (ATR(width lookback) * ATR width weight + STDEV(close, width lookback) * deviation width weight) * width multiplier
Calculation: Upper corridor = Adaptive baseline + Hybrid width
Calculation: Lower corridor = Adaptive baseline - Hybrid width
Calculation: Inner upper = Adaptive baseline + Hybrid width * inner band factor
Calculation: Inner lower = Adaptive baseline - Hybrid width * inner band factor
Calculation: Typical price = (high + low + close) / 3
Calculation: VWAP(x, v, n) = SUM(x * v, n) / SUM(v, n) if SUM(v, n) > 0 else SMA(x, n)
Calculation: Value area low = VWAP(Typical price, volume, auction lookback) - STDEV(Typical price, auction lookback) * value area width
Calculation: Value area high = VWAP(Typical price, volume, auction lookback) + STDEV(Typical price, auction lookback) * value area width
Calculation: Raw pressure = ((close - open) / (high - low) * effort weight + tanh((close - open) / ATR(ATR lookback) * result gain) * result weight + CLV(high, low, close) * location weight) * volume / SMA(volume, pressure volume lookback)
Calculation: Pressure = EMA(Raw pressure, pressure smoothing lookback)
Calculation: Pressure signal line = EMA(Pressure, slow pressure lookback)
Calculation: Divergence oscillator = EMA(RSI(close, RSI lookback) * RSI weight + ROC(close, ROC lookback), oscillator smoothing lookback)
Calculation: Bear divergence event = a bar where PivotHigh(high, pivot left, pivot right) and PivotHigh(Divergence oscillator, pivot left, pivot right) both occur, high[pivot right] > the high[pivot right] stored at the previous such bar, and Divergence oscillator[pivot right] < the Divergence oscillator[pivot right] stored at that bar
Calculation: Bull divergence event = a bar where PivotLow(low, pivot left, pivot right) and PivotLow(Divergence oscillator, pivot left, pivot right) both occur, low[pivot right] < the low[pivot right] stored at the previous such bar, and Divergence oscillator[pivot right] > the Divergence oscillator[pivot right] stored at that bar
Calculation: Bear divergence active = BarsSince(Bear divergence event AND bar is confirmed) < divergence suppression window
Calculation: Bull divergence active = BarsSince(Bull divergence event AND bar is confirmed) < divergence suppression window
Calculation: Bars in trade = bars since the position last changed from flat to open, or 0 when flat
Calculation: Long stop = MAX(entry price - ATR(ATR lookback) * stop ATR multiple, Lower corridor - ATR(ATR lookback) * corridor stop ATR multiple, Adaptive baseline - ATR(ATR lookback) * trail ATR multiple)
Calculation: Short stop = MIN(entry price + ATR(ATR lookback) * stop ATR multiple, Upper corridor + ATR(ATR lookback) * corridor stop ATR multiple, Adaptive baseline + ATR(ATR lookback) * trail ATR multiple)
Long: bar is confirmed AND Directional regime > bull regime threshold AND close > Adaptive baseline AND Adaptive baseline > Adaptive baseline[1] AND low <= Inner upper AND close > Adaptive baseline - ATR(ATR lookback) * pullback tolerance AND close <= Upper corridor AND (NOT require auction acceptance OR (close >= Value area low AND close <= Value area high)) AND (NOT require VWAP alignment OR close >= VWAP(Typical price, volume, auction lookback)) AND Pressure > pressure threshold AND Pressure > Pressure signal line AND (NOT require expansion OR ZScore(high - low, volatility lookback) > minimum range z-score) AND (NOT use divergence guard OR NOT Bear divergence active)
Short: bar is confirmed AND Directional regime < bear regime threshold AND close < Adaptive baseline AND Adaptive baseline < Adaptive baseline[1] AND high >= Inner lower AND close < Adaptive baseline + ATR(ATR lookback) * pullback tolerance AND close >= Lower corridor AND (NOT require auction acceptance OR (close >= Value area low AND close <= Value area high)) AND (NOT require VWAP alignment OR close <= VWAP(Typical price, volume, auction lookback)) AND Pressure < -pressure threshold AND Pressure < Pressure signal line AND (NOT require expansion OR ZScore(high - low, volatility lookback) > minimum range z-score) AND (NOT use divergence guard OR NOT Bull divergence active)
Exit: long, low <= Long stop OR high >= entry price + ATR(ATR lookback) * target ATR multiple
Exit: short, high >= Short stop OR low <= entry price - ATR(ATR lookback) * target ATR multiple
Exit: long, Directional regime < 0 OR Pressure < 0 OR close < Adaptive baseline OR Bars in trade >= max bars in trade OR Bear divergence active
Exit: short, Directional regime > 0 OR Pressure > 0 OR close > Adaptive baseline OR Bars in trade >= max bars in trade OR Bull divergence active
Long: bar is confirmed AND Pressure crosses above Pressure signal line
Short: bar is confirmed AND Pressure crosses below Pressure signal line