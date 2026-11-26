Calculation: Bullish BOS = close crosses above highest(high, structure lookback)[1]
Calculation: Bearish BOS = close crosses below lowest(low, structure lookback)[1]
Calculation: Market bias = bullish after the latest bullish BOS, bearish after the latest bearish BOS, and unset before either BOS
Calculation: Bullish liquidity sweep = low < lowest(low, liquidity lookback)[1] AND close > lowest(low, liquidity lookback)[1]
Calculation: Bearish liquidity sweep = high > highest(high, liquidity lookback)[1] AND close < highest(high, liquidity lookback)[1]
Calculation: Volume threshold = SMA(volume, volume average lookback) * volume multiplier
Long: bullish BOS
Short: bearish BOS
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: market bias is bullish
Short: market bias is bearish or unset
Long: low > high[2] AND close[1] > high[2]
Short: high < low[2] AND close[1] < low[2]
Long: close > open AND close > high[1] AND volume > volume threshold
Short: close < open AND close < low[1] AND volume > volume threshold
Long: bullish liquidity sweep
Short: bearish liquidity sweep
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND market bias is bullish AND volume > volume threshold AND abs(EMA(close, shorter lookback) - EMA(close, longer lookback)) > ATR(ATR lookback) * chop threshold AND bullish liquidity sweep
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND market bias is bearish AND volume > volume threshold AND abs(EMA(close, shorter lookback) - EMA(close, longer lookback)) > ATR(ATR lookback) * chop threshold AND bearish liquidity sweep