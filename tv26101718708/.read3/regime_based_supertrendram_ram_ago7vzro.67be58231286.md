Calculation: Bullish regime score = count of true conditions among RSI(close, long-side RSI lookback) > long-side RSI threshold, close > EMA(close, EMA lookback), chart-timeframe SuperTrend(ATR multiplier, ATR period) bullish, volume > SMA(volume, volume lookback), and SuperTrend(ATR multiplier, ATR period) bullish calculated on T1 bars and sampled on each chart bar from T1's still-forming bar
Calculation: EMA stretch percentage = ((close - EMA(close, EMA lookback)) / EMA(close, EMA lookback)) * 100
Calculation: Long setup = Bullish regime score >= 4 AND abs(EMA stretch percentage) <= maximum stretch percentage
Calculation: Short setup = chart-timeframe SuperTrend(ATR multiplier, ATR period) bearish AND close < EMA(close, EMA lookback) AND RSI(close, short-side RSI lookback) < short-side RSI threshold
Long: chart-timeframe SuperTrend(ATR multiplier, ATR period) bullish
Short: chart-timeframe SuperTrend(ATR multiplier, ATR period) bearish
Long: Bullish regime score >= 4
Short: Bullish regime score <= 2
Long: Long setup AND NOT Long setup[1]
Short: Short setup AND NOT Short setup[1]