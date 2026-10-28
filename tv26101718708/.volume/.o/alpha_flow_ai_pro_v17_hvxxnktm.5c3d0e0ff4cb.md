Calculation: AI confidence = capped sum of trend-alignment, ADX-strength, RSI, MACD, relative-volume, money-flow, CCI, and momentum-alignment scores
Calculation: Higher-timeframe trend = fast EMA compared with slower EMA on each of four configured higher timeframes, using bars still forming
Long: fast EMA > medium EMA AND medium EMA > slow EMA
Short: fast EMA < medium EMA AND medium EMA < slow EMA
Long: fast EMA > medium EMA AND medium EMA > slow EMA AND RSI > 45 AND close > trailing stop AND AI confidence >= premium threshold AND at least three of four higher-timeframe trends are bullish
Short: fast EMA < medium EMA AND medium EMA < slow EMA AND RSI < 55 AND close < trailing stop AND AI confidence >= premium threshold AND at least three of four higher-timeframe trends are bearish
Long: fast EMA crosses above medium EMA AND AI confidence >= minimum confidence AND premium long condition is false
Short: fast EMA crosses below medium EMA AND AI confidence >= minimum confidence AND premium short condition is false
Long: close <= lower Bollinger band AND RSI < 30 AND close crosses above lower Bollinger band AND AI confidence >= minimum confidence
Short: close >= upper Bollinger band AND RSI > 70 AND close crosses below upper Bollinger band AND AI confidence >= minimum confidence
Long: candle closes above its open AND candle body > 2 × 20-bar average candle body AND volume > 1.3 × 20-bar average volume
Short: candle closes below its open AND candle body > 2 × 20-bar average candle body AND volume > 1.3 × 20-bar average volume
Exit: Long, low <= entry price − ATR × stop-loss multiplier calculated at entry
Exit: Short, high >= entry price + ATR × stop-loss multiplier calculated at entry