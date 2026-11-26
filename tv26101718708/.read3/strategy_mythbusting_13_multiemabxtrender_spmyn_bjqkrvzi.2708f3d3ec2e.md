Calculation: ShortOsc = RSI(EMA(close, short-term shorter EMA lookback) - EMA(close, short-term longer EMA lookback), short-term RSI lookback)
Calculation: ShortOscT3 = T3(ShortOsc, T3 lookback, T3 volume factor)
Calculation: OscTurnUp = ShortOscT3 > ShortOscT3[1] AND ShortOscT3[1] < ShortOscT3[2]
Calculation: OscTurnDown = ShortOscT3 < ShortOscT3[1] AND ShortOscT3[1] > ShortOscT3[2]
Calculation: LongOsc = RSI(EMA(close, long-term EMA lookback), long-term RSI lookback)
Calculation: PullbackLong = BarsSince((low - EMA(close, middle EMA lookback)) / low * 100 <= pullback percent) <= pullback lookback
Calculation: PullbackShort = BarsSince((EMA(close, middle EMA lookback) - high) / EMA(close, middle EMA lookback) * 100 <= pullback percent) <= pullback lookback
Long: OscTurnUp
Long: PullbackLong AND NOT PullbackLong[1]
Long: EMA(close, shortest EMA lookback) > EMA(close, longest EMA lookback)
Long: EMA(close, shortest EMA lookback) > EMA(close, middle EMA lookback) + minimum EMA distance AND EMA(close, middle EMA lookback) > EMA(close, longest EMA lookback) + minimum EMA distance AND PullbackLong AND OscTurnUp AND LongOsc > RSI midline AND LongOsc > LongOsc[1] AND close > EMA(close, shortest EMA lookback) AND (ADX filter disabled OR ADX(DI length, ADX smoothing) > ADX threshold)
Short: OscTurnDown
Short: PullbackShort AND NOT PullbackShort[1]
Short: EMA(close, shortest EMA lookback) <= EMA(close, longest EMA lookback)
Short: EMA(close, shortest EMA lookback) < EMA(close, middle EMA lookback) - minimum EMA distance AND EMA(close, middle EMA lookback) < EMA(close, longest EMA lookback) - minimum EMA distance AND PullbackShort AND OscTurnDown AND LongOsc < RSI midline AND LongOsc < LongOsc[1] AND close < EMA(close, shortest EMA lookback) AND (ADX filter disabled OR ADX(DI length, ADX smoothing) > ADX threshold)
Exit: long, use close signal AND (OscTurnDown OR OscTurnUp)
Exit: short, use close signal AND (OscTurnDown OR OscTurnUp)
Exit: long, close < entry price * (1 - stop loss percent)
Exit: short, close > entry price * (1 + stop loss percent)
Exit: long, high >= entry price * (1 + take profit 1 percent)
Exit: long, high >= entry price * (1 + take profit 2 percent)
Exit: long, high >= entry price * (1 + take profit 3 percent)
Exit: long, high >= entry price * (1 + take profit 4 percent)
Exit: short, low <= entry price * (1 - take profit 1 percent)
Exit: short, low <= entry price * (1 - take profit 2 percent)
Exit: short, low <= entry price * (1 - take profit 3 percent)
Exit: short, low <= entry price * (1 - take profit 4 percent)