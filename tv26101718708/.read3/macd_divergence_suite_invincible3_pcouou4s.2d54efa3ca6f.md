Calculation: TypedMA(x, lookback, MA type) = MA of x over lookback bars of the given MA type
Calculation: MACD(x) = TypedMA(x, shorter lookback, fast MA type) - TypedMA(x, longer lookback, slow MA type)
Calculation: MACDSignal(x) = TypedMA(MACD(x), signal lookback, signal MA type)
Calculation: MACDHist(x) = MACD(x) - MACDSignal(x)
Calculation: NormMACD(x) = 100 * MACD(x) / Highest(Abs(MACD(x)), norm lookback), or 0 if that Highest is 0
Calculation: NormSignal(x) = 100 * MACDSignal(x) / Highest(Abs(MACD(x)), norm lookback), or 0 if that Highest is 0
Calculation: NormHist(x) = 100 * MACDHist(x) / Highest(Abs(MACDHist(x)), norm lookback), or 0 if that Highest is 0
Calculation: PivotLow(x, length) = x[length] if x[length] = Lowest(x, 2 * length + 1), else na
Calculation: PivotHigh(x, length) = x[length] if x[length] = Highest(x, 2 * length + 1), else na
Long: NormMACD(price source) crosses above NormSignal(price source) AND NormMACD(price source) <= bull signal level
Short: NormMACD(price source) crosses below NormSignal(price source) AND NormMACD(price source) >= bear signal level
Long: NormHist(price source) crosses above oscillator level
Short: NormHist(price source) crosses below oscillator level
Long: low[pivot length] < ValueWhen(PivotLow(NormHist(price source), pivot length) is defined, low[pivot length], 1) AND PivotLow(NormHist(price source), pivot length) > ValueWhen(PivotLow(NormHist(price source), pivot length) is defined, PivotLow(NormHist(price source), pivot length), 1) AND (PivotLow(NormHist(price source), pivot length) <= divergence oversold level OR ValueWhen(PivotLow(NormHist(price source), pivot length) is defined, PivotLow(NormHist(price source), pivot length), 1) <= divergence oversold level)
Short: high[pivot length] > ValueWhen(PivotHigh(NormHist(price source), pivot length) is defined, high[pivot length], 1) AND PivotHigh(NormHist(price source), pivot length) < ValueWhen(PivotHigh(NormHist(price source), pivot length) is defined, PivotHigh(NormHist(price source), pivot length), 1) AND (PivotHigh(NormHist(price source), pivot length) >= divergence overbought level OR ValueWhen(PivotHigh(NormHist(price source), pivot length) is defined, PivotHigh(NormHist(price source), pivot length), 1) >= divergence overbought level)
Long: close > SMA(close, SMA lookback)
Short: close < SMA(close, SMA lookback)
Long: NormMACD(price source) >= NormSignal(price source)
Short: NormMACD(price source) < NormSignal(price source)
Long: NormMACD(price source) > NormSignal(price source) AND NormMACD(price source) > NormMACD(price source)[1]
Short: NormMACD(price source) < NormSignal(price source) AND NormMACD(price source) < NormMACD(price source)[1]
Long: NormHist(price source) >= oscillator level
Short: NormHist(price source) < oscillator level