Calculation: Normalized value(x) = x / SMA(abs(x), lookback); use the same lookback for all normalized values
Calculation: Volume spike = volume > SMA(volume, lookback) × volume multiplier
Calculation: Up flow = close > previous close AND previous close > close two bars ago; down flow = close < previous close AND previous close < close two bars ago
Calculation: Compression = abs(close − previous close) < SMA(abs(close − previous close), lookback) × compression multiplier AND abs(previous close − close two bars ago) < SMA(abs(close − previous close), lookback) × compression multiplier
Calculation: Flow score = (up flow ? 1 : down flow ? −1 : 0) + (volume spike ? 1 : 0) + (compression ? −1 : 1)
Calculation: ADX support = SMA(ADX, support lookback)
Calculation: ADX boost = ADX > ADX support ? 2 : −1.5
Calculation: MACD boost = MACD histogram > 0 ? min(MACD histogram × 5, 3) : max(MACD histogram × 5, −3)
Calculation: RSI penalty = RSI > 75 ? −3 : RSI > 70 ? −2 : RSI < 25 ? 3 : RSI < 30 ? 2 : 0
Calculation: Final score = normalized ATR + normalized (close − previous close) + normalized (OBV − EMA(OBV, lookback)) + normalized ROC(close, lookback) + normalized (ATR / max(SMA(ATR, lookback), 1)) + normalized (EMA(close, 9) − EMA(close, 21)) + flow score + ADX boost + MACD boost + RSI penalty
Calculation: Signal state = 1 after a long condition, −1 after a short condition, otherwise retain the prior value; starts at 0
Long: up flow AND volume spike AND NOT compression AND final score > 3 AND signal state ≠ 1
Short: down flow AND volume spike AND NOT compression AND final score < −3 AND signal state ≠ −1