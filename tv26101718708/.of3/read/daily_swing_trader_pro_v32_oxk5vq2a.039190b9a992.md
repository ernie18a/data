Calculation: CandleRange = high - low
Calculation: ExtensionAbove = (close - EMA(close, longer EMA lookback)) / ATR(high, low, close, ATR lookback)
Calculation: ExtensionBelow = (EMA(close, longer EMA lookback) - close) / ATR(high, low, close, ATR lookback)
Calculation: RelativeVolume = volume / SMA(volume, volume lookback)
Calculation: LongStopLevel = Lowest(low, stop lookback) - ATR(high, low, close, ATR lookback) * stop buffer
Calculation: ShortStopLevel = Highest(high, stop lookback) + ATR(high, low, close, ATR lookback) * stop buffer
Calculation: LongSetup = (close > Highest(high, breakout lookback)[1] AND close > open) OR (low <= EMA(close, shorter EMA lookback) AND low >= EMA(close, longer EMA lookback) - ATR(high, low, close, ATR lookback) * pullback ATR allowance AND close > EMA(close, shorter EMA lookback) AND close > EMA(close, longer EMA lookback) AND close > high[1] AND close > open)
Calculation: ShortSetup = (close < Lowest(low, breakout lookback)[1] AND close < open) OR (high >= EMA(close, shorter EMA lookback) AND high <= EMA(close, longer EMA lookback) + ATR(high, low, close, ATR lookback) * pullback ATR allowance AND close < EMA(close, shorter EMA lookback) AND close < EMA(close, longer EMA lookback) AND close < low[1] AND close < open)
Calculation: LongFilter = chart timeframe is T1 AND close > SMA(close, shorter SMA lookback) AND close > SMA(close, longer SMA lookback) AND close > EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback) AND EMA(close, longer EMA lookback) > EMA(close, longer EMA lookback)[1] AND SuperTrend(high, low, close, SuperTrend factor, SuperTrend ATR lookback) is bullish AND RSI(close, RSI lookback) > long RSI floor AND RSI(close, RSI lookback) < long RSI ceiling AND RelativeVolume >= normal RVOL threshold AND NATR(high, low, close, ATR lookback) >= minimum ATR percent AND ExtensionAbove <= maximum extension
Calculation: ShortFilter = chart timeframe is T1 AND close < SMA(close, shorter SMA lookback) AND close < SMA(close, longer SMA lookback) AND close < EMA(close, longer EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback) AND EMA(close, longer EMA lookback) < EMA(close, longer EMA lookback)[1] AND SuperTrend(high, low, close, SuperTrend factor, SuperTrend ATR lookback) is bearish AND RSI(close, RSI lookback) < short RSI ceiling AND RSI(close, RSI lookback) > short RSI floor AND RelativeVolume >= normal RVOL threshold AND NATR(high, low, close, ATR lookback) >= minimum ATR percent AND ExtensionBelow <= maximum extension
Calculation: LongCandidate = LongFilter AND LongSetup
Calculation: StrongLongCandidate = LongFilter AND RSI(close, RSI lookback) >= strong long RSI floor AND RSI(close, RSI lookback) <= strong long RSI ceiling AND RelativeVolume >= strong RVOL threshold AND close >= high - CandleRange * close-position fraction AND LongSetup
Calculation: ShortCandidate = ShortFilter AND ShortSetup
Calculation: StrongShortCandidate = ShortFilter AND RSI(close, RSI lookback) >= strong short RSI floor AND RSI(close, RSI lookback) <= strong short RSI ceiling AND RelativeVolume >= strong RVOL threshold AND close <= low + CandleRange * close-position fraction AND ShortSetup
Long: position side is flat AND StrongLongCandidate AND NOT StrongLongCandidate[1]
Long: position side is flat AND LongCandidate AND NOT StrongLongCandidate AND NOT LongCandidate[1]
Short: position side is flat AND StrongShortCandidate AND NOT StrongShortCandidate[1]
Short: position side is flat AND ShortCandidate AND NOT StrongShortCandidate AND NOT ShortCandidate[1]
Exit: long, low <= LongStopLevel[bars since entry]
Exit: long, high >= entry price + (entry price - LongStopLevel[bars since entry]) * reward-risk multiple
Exit: short, high >= ShortStopLevel[bars since entry]
Exit: short, low <= entry price - (ShortStopLevel[bars since entry] - entry price) * reward-risk multiple