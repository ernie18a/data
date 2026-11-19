Calculation: bullish trend = close > EMA(close, longer EMA lookback)
Calculation: bearish trend = close < EMA(close, longer EMA lookback)
Calculation: bullish BOS = close > latest confirmed Pivot High(high, pivot left lookback, pivot right lookback)
Calculation: bearish BOS = close < latest confirmed Pivot Low(low, pivot left lookback, pivot right lookback)
Calculation: bullish liquidity grab = low < Lowest(low, liquidity lookback)[1] AND close > open
Calculation: bearish liquidity grab = high > Highest(high, liquidity lookback)[1] AND close < open
Calculation: high volume = volume > SMA(volume, volume average lookback) * volume multiplier
Long: bullish trend
Short: bearish trend
Long: bullish BOS
Short: bearish BOS
Long: bullish liquidity grab
Short: bearish liquidity grab
Long: close[1] < open[1] AND close > high[1]
Short: close[1] > open[1] AND close < low[1]
Long: bullish trend AND EMA(close, shorter EMA lookback) crosses above EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) > long RSI threshold AND bullish liquidity grab AND (volume filter disabled OR high volume) AND (BOS filter disabled OR bullish BOS)
Short: bearish trend AND EMA(close, shorter EMA lookback) crosses below EMA(close, longer EMA lookback) AND RSI(close, RSI lookback) < short RSI threshold AND bearish liquidity grab AND (volume filter disabled OR high volume) AND (BOS filter disabled OR bearish BOS)