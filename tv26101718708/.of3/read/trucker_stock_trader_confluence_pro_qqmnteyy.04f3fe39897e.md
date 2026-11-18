Long: MACD(close, shorter lookback, longer lookback, signal lookback).line crosses above its signal line
Short: MACD(close, shorter lookback, longer lookback, signal lookback).line crosses below its signal line
Long: RSI(close, lookback) crosses above threshold
Short: RSI(close, lookback) crosses below threshold
Long: EMA(close, fast lookback) crosses above EMA(close, separate short lookback) OR EMA(close, medium lookback)
Short: EMA(close, fast lookback) crosses below EMA(close, separate short lookback) OR EMA(close, medium lookback)
Long: close crosses above Keltner Channel(close, lookback, multiplier).upper
Short: close crosses below Keltner Channel(close, lookback, multiplier).lower
Long: close crosses above VWAP(hlc3)
Short: close crosses below VWAP(hlc3)
Long: MACD(close, shorter lookback, longer lookback, signal lookback).line > its signal line
Short: MACD(close, shorter lookback, longer lookback, signal lookback).line <= its signal line
Long: RSI(close, lookback) > threshold
Short: RSI(close, lookback) <= threshold
Long: EMA(close, fast lookback) > EMA(close, medium lookback)
Short: EMA(close, fast lookback) <= EMA(close, medium lookback)
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: close > Keltner Channel(close, lookback, multiplier).basis
Short: close <= Keltner Channel(close, lookback, multiplier).basis
Calculation: bullish agreement count = number of true comparisons among MACD(close, shorter lookback, longer lookback, signal lookback).line > its signal line, RSI(close, lookback) > threshold, EMA(close, fast lookback) > EMA(close, medium lookback), close > VWAP(hlc3), and close > Keltner Channel(close, lookback, multiplier).basis
Long: bullish agreement count >= high score threshold
Long: bullish agreement count >= middle score threshold AND bullish agreement count < high score threshold
Long: bullish agreement count >= low score threshold AND bullish agreement count < middle score threshold