Calculation: volume spike = volume > SMA(volume, volume lookback) * volume multiplier
Calculation: bullish sweep = low < lowest(low, liquidity lookback)[1] * (1 + sweep tolerance / 100) AND close > lowest(low, liquidity lookback)[1] AND high > open AND volume spike
Calculation: bearish sweep = high > highest(high, liquidity lookback)[1] * (1 - sweep tolerance / 100) AND close < highest(high, liquidity lookback)[1] AND low < open AND volume spike
Calculation: bullish higher-timeframe bias = T1 close > EMA(close, shorter lookback, on T1 bars) AND EMA(close, shorter lookback, on T1 bars) > EMA(close, longer lookback, on T1 bars), sampled on chart bars using the last completed T1 bar historically and the still-forming T1 bar in real time
Calculation: bearish higher-timeframe bias = T1 close < EMA(close, shorter lookback, on T1 bars) AND EMA(close, shorter lookback, on T1 bars) < EMA(close, longer lookback, on T1 bars), sampled on chart bars using the last completed T1 bar historically and the still-forming T1 bar in real time
Calculation: bullish FVG = low > high[2] AND low - high[2] >= minimum gap size
Calculation: bearish FVG = low[2] > high AND low[2] - high >= minimum gap size
Calculation: bullish rejection wick = (min(close, open) - low) / (high - low) >= wick ratio AND close > open
Calculation: bearish rejection wick = (high - max(close, open)) / (high - low) >= wick ratio AND close < open
Long: bullish higher-timeframe bias
Short: bearish higher-timeframe bias
Long: bullish sweep
Short: bearish sweep
Long: bullish FVG
Short: bearish FVG
Long: bullish rejection wick
Short: bearish rejection wick
Long: volume spike AND close > open
Short: volume spike AND close < open
Long: bullish higher-timeframe bias AND bullish sweep on the preceding chart bar AND bullish FVG AND bullish rejection wick AND volume spike
Short: bearish higher-timeframe bias AND bearish sweep on the preceding chart bar AND bearish FVG AND bearish rejection wick AND volume spike