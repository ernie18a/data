Calculation: Ribbon midpoint = (fast EMA + slow EMA) / 2; upper ribbon = midpoint + ATR × ribbon multiplier; lower ribbon = midpoint − ATR × ribbon multiplier
Calculation: Bullish engulfing = close > open AND previous close < previous open AND close ≥ previous open AND open ≤ previous close
Calculation: Bearish engulfing = close < open AND previous close > previous open AND close ≤ previous open AND open ≥ previous close
Calculation: Bullish pin bar = lower wick > candle body × wick-to-body ratio AND upper wick < candle body AND close > open
Calculation: Bearish pin bar = upper wick > candle body × wick-to-body ratio AND lower wick < candle body AND close < open
Calculation: Long stop = entry price − ATR × stop multiplier; long target = entry price + ATR × stop multiplier × risk-reward ratio
Calculation: Short stop = entry price + ATR × stop multiplier; short target = entry price − ATR × stop multiplier × risk-reward ratio
Long: fast EMA (shorter lookback) > slow EMA (longer lookback) AND fast EMA > its previous value AND RSI ≥ bullish threshold AND ((close crosses above upper ribbon) OR (bullish engulfing OR bullish pin bar)) AND (volume confirmation disabled OR volume > volume SMA × volume multiplier) AND (MACD confirmation disabled OR MACD line > signal line)
Short: fast EMA (shorter lookback) < slow EMA (longer lookback) AND fast EMA < its previous value AND RSI ≤ bearish threshold AND ((close crosses below lower ribbon) OR (bearish engulfing OR bearish pin bar)) AND (volume confirmation disabled OR volume > volume SMA × volume multiplier) AND (MACD confirmation disabled OR MACD line < signal line)
Exit: long, high ≥ long target OR low ≤ long stop
Exit: short, low ≤ short target OR high ≥ short stop