Calculation: candle body = abs(close - open)
Calculation: candle range = high - low
Long: previous close > previous open AND close < open AND volume > previous volume AND low >= previous low AND candle body > 0.10 × candle range AND (candle body > 0.30 × candle range OR (close - low) < 2 × candle body AND (high - close) < 2 × candle body)
Short: previous close < previous open AND close > open AND volume > previous volume AND high <= previous high AND candle body > 0.10 × candle range AND (candle body > 0.30 × candle range OR (close - low) < 2 × candle body AND (high - close) < 2 × candle body)