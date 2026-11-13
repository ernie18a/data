Calculation: HTFopen = open of the still-forming bar of a timeframe higher than the chart timeframe
Calculation: MTFclose = close of the still-forming bar of a timeframe higher than the chart timeframe but shorter than the HTFopen timeframe
Calculation: Rng = high - low; Body = |close - open|; [1] = previous chart bar
Calculation: BullPin = open > low + k*Rng AND close > low + k*Rng (k = large fraction); BearPin = open < high - k*Rng AND close < high - k*Rng (same k)
Calculation: PiercingLine = close[1] < open[1] AND Body[1]/Rng[1] >= r AND close > open AND Body/Rng >= r AND open <= close[1] AND close < open[1] AND close > (open[1]+close[1])/2 (r = large fraction, same for both bars)
Calculation: DarkCloud = close[1] > open[1] AND Body[1]/Rng[1] >= r AND close < open AND Body/Rng >= r AND open >= close[1] AND close > open[1] AND close < (open[1]+close[1])/2 (same r)
Calculation: BullHarami = open[1] > close[1] AND close > open AND close <= open[1] AND high <= open[1] AND (close-open) < (open[1]-close[1]) AND high < high[1] AND low > low[1]
Calculation: BearHarami = close[1] > open[1] AND open > close AND open <= close[1] AND low >= open[1] AND (open-close) < (close[1]-open[1]) AND high < high[1] AND low > low[1]
Calculation: BullEngulf = close[1] < open[1] AND close > open AND close >= high[1] AND open <= close[1]
Calculation: BearEngulf = close[1] > open[1] AND close < open AND close <= low[1] AND open >= close[1]
Calculation: TopFractal = high of the bar 2 bars back whenever it is strictly greater than the highs of the 2 bars before and the 2 bars after it, held until the next one forms; BotFractal = same with lows, strictly lower
Calculation: BullPattern = BullPin OR PiercingLine OR BullHarami OR BullEngulf OR close crosses above TopFractal
Calculation: BearPattern = BearPin OR DarkCloud OR BearHarami OR BearEngulf OR close crosses below BotFractal
Calculation: ReversalPinUp = open > high - (1-q)*Rng AND close > high - (1-q)*Rng AND low <= lowest low of the last N bars including current (q = large fraction, N = short lookback); ReversalPinDn = open < high - q*Rng AND close < high - q*Rng AND high >= highest high of the last N bars including current (same q, N)
Calculation: ShavedUp = close >= high - s*Rng; ShavedDn = close <= low + s*Rng (s = small fraction)
Calculation: MACD = EMA(close, short) - EMA(close, long); MacdUp = (MACD > 0 AND MACD > MACD[1]) OR (MACD <= 0 AND MACD >= MACD[1]); MacdDn = NOT MacdUp
Calculation: HullMA = Hull moving average of close
Long: MTFclose crosses above HTFopen OR (close > HTFopen AND BullPattern AND position is flat)
Long: ReversalPinUp
Long: MacdUp AND HullMA > HullMA[1] AND (BullPattern OR ShavedUp)
Short: MTFclose crosses below HTFopen OR (close < HTFopen AND BearPattern AND position is flat)
Short: ReversalPinDn
Short: MacdDn AND HullMA < HullMA[1] AND (BearPattern OR ShavedDn)
Exit: long, MTFclose crosses below HTFopen
Exit: short, MTFclose crosses above HTFopen