Calculation: Bullish volume POC = price bin with the greatest accumulated volume in the current, still-forming higher-timeframe bar, counting bars whose typical price (high + low + close) / 3 is at or above that bar’s open; assign each bar’s full volume to the nearest bin.
Calculation: Bearish volume POC = price bin with the greatest accumulated volume in the current, still-forming higher-timeframe bar, counting bars whose typical price (high + low + close) / 3 is below that bar’s open; assign each bar’s full volume to the nearest bin.
Long: Current higher-timeframe low >= its open OR (current higher-timeframe low < its open AND current higher-timeframe high > its open AND close > its open)
Long: Low < previous completed higher-timeframe low AND prior bar’s low >= that level
Long: Low <= bearish volume POC AND close > bullish volume POC
Short: Current higher-timeframe high <= its open OR (current higher-timeframe high > its open AND current higher-timeframe low < its open AND close < its open)
Short: High > previous completed higher-timeframe high AND prior bar’s high <= that level
Short: High >= bullish volume POC AND close < bearish volume POC