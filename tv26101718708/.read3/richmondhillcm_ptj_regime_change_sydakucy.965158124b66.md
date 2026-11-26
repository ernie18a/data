Calculation: MovingAvg(close, lookback) = EMA(close, lookback) or SMA(close, lookback), per average type
Calculation: VolatilityRatio = ATR(high, low, close, ATR lookback) / SMA(ATR(high, low, close, ATR lookback), ATR normalization lookback)
Calculation: MACDHistogram = MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback)
Calculation: RegimeScore = sum of the votes: +1 if close > MovingAvg(close, longer lookback), else -1; +1 if close > MovingAvg(close, shorter lookback), else -1; +1 if MovingAvg(close, longer lookback) > MovingAvg(close, longer lookback)[slope lookback] AND MovingAvg(close, shorter lookback) > MovingAvg(close, shorter lookback)[slope lookback], else -1; +1 if RSI band floor <= RSI(close, RSI lookback) < RSI band ceiling, else -1; +1 if MACDHistogram > 0 AND MACDHistogram > MACDHistogram[1], -1 if MACDHistogram < 0 AND MACDHistogram < MACDHistogram[1], else 0; +1 if volume > SMA(volume, volume lookback) AND close > close[1], -1 if volume > SMA(volume, volume lookback) AND close < close[1], else 0; +1 if VolatilityRatio < calm ratio, -1 if VolatilityRatio > stress ratio, else 0
Long: RegimeScore >= bull threshold
Long: RegimeScore >= bull threshold AND RegimeScore[1] < bull threshold
Long: close crosses above MovingAvg(close, longer lookback)
Short: RegimeScore <= bear threshold
Short: RegimeScore <= bear threshold AND RegimeScore[1] > bear threshold
Short: close crosses below MovingAvg(close, longer lookback)
Exit: long, RSI(close, RSI lookback) >= RSI band ceiling