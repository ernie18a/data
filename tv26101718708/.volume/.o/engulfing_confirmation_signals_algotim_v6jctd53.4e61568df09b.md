Calculation: Bullish engulfing = close > open AND previous bar close < previous bar open AND (full-body engulfing is required OR close > previous bar open AND open < previous bar close) AND abs(close - open) >= abs(previous bar close - previous bar open) × minimum body ratio
Calculation: Bearish engulfing = close < open AND previous bar close > previous bar open AND (full-body engulfing is required OR close < previous bar open AND open > previous bar close) AND abs(close - open) >= abs(previous bar close - previous bar open) × minimum body ratio
Calculation: Bullish trend score = 40 if close > EMA(close, trend lookback), otherwise 20 if close > EMA(close, trend lookback) × 0.998, otherwise 0
Calculation: Bearish trend score = 40 if close < EMA(close, trend lookback), otherwise 20 if close < EMA(close, trend lookback) × 1.002, otherwise 0
Calculation: Volume score = min((volume / SMA(volume, volume lookback)) × 20, 30); use 1 as the volume ratio if the average volume is not positive
Calculation: ATR score = max(min(((ATR / SMA(ATR, ATR lookback)) - 1) × 60 + 10, 30), 0); use 1 as the ATR ratio if the ATR average is not positive
Calculation: Bullish quality score = bullish trend score + volume score + ATR score
Calculation: Bearish quality score = bearish trend score + volume score + ATR score
Long: bullish engulfing AND bullish quality score >= minimum quality score OR a qualified bullish setup is active and close > that setup's high within the confirmation waiting period
Short: bearish engulfing AND bearish quality score >= minimum quality score OR a qualified bearish setup is active and close < that setup's low within the confirmation waiting period