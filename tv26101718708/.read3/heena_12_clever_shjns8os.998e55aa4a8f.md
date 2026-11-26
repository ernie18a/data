Calculation: FastMA = MA(close, shorter lookback, MA type, T1, last completed bar)
Calculation: BullishTrend = FastMA > MA(close, longer lookback, MA type, T1, last completed bar)
Calculation: TrendChange = BullishTrend != BullishTrend[1], on T1 bars, last completed bar
Calculation: TrendAdjustedMA = FastMA - ATR(trend ATR lookback, T1, last completed bar) if BullishTrend, else FastMA + ATR(trend ATR lookback, T1, last completed bar)
Calculation: TypicalPrice = (high + low + close) / 3
Calculation: UpperBand = GaussianNadarayaWatson(BollingerUpper(TypicalPrice, band lookback, band deviation), smoothing lookback, smoothing bandwidth)
Calculation: LowerBand = GaussianNadarayaWatson(BollingerLower(TypicalPrice, band lookback, band deviation), smoothing lookback, smoothing bandwidth)
Calculation: ShortATR = ATR(shorter ATR lookback)
Calculation: Volatile = ShortATR > volatility factor * ATR(longer ATR lookback)
Calculation: Cooldown = MAX(minimum cooldown, ROUND(base cooldown * ATR(longer cooldown ATR lookback) / ShortATR))
Calculation: BarsSinceRetest = IF (RetestLong[1] OR RetestShort[1]) THEN 1 ELSE BarsSinceRetest[1] + 1
Calculation: PriorSignal = (PriorSignal[1] OR RetestLong[1] OR RetestShort[1]) AND NOT TrendChange
Calculation: RetestLong = Volatile AND low(T1, last completed bar) crosses above TrendAdjustedMA AND NOT TrendChange AND BullishTrend AND BarsSinceRetest > Cooldown AND NOT PriorSignal AND close > LowerBand
Calculation: RetestShort = Volatile AND high(T1, last completed bar) crosses below TrendAdjustedMA AND NOT TrendChange AND NOT BullishTrend AND BarsSinceRetest > Cooldown AND NOT PriorSignal AND close < UpperBand
Long: RetestLong
Long: close crosses above LowerBand AND NOT PriorSignal
Long: BullishTrend
Short: RetestShort
Short: close crosses below UpperBand AND NOT PriorSignal
Short: NOT BullishTrend