Calculation: WaveTrend gap(T1) = WaveTrend fast(T1) - WaveTrend slow(T1), using the WaveTrend parameters; sample the latest available T1 value on chart bars (the forming T1 bar in real time, the last completed T1 bar historically)
Calculation: Money flow = SMA(((close - open) / (high - low)) * multiplier, lookback) - offset
Calculation: Confirmed fractal high(X) = X[2] > X[0] AND X[2] > X[1] AND X[2] > X[3] AND X[2] > X[4]
Calculation: Confirmed fractal low(X) = X[2] < X[0] AND X[2] < X[1] AND X[2] < X[3] AND X[2] < X[4]
Calculation: Realtime bullish RSI divergence = for the first matching prior confirmed close pivot among the configured pivot count and bar limit, more than five bars away, RSI at the current or previous bar (per confirmation setting) is higher than pivot RSI and close is lower than pivot close (regular), or RSI is lower and close is higher (hidden), with both RSI and close staying above their straight lines between endpoints
Calculation: Realtime bearish RSI divergence = for the first matching prior confirmed close pivot among the configured pivot count and bar limit, more than five bars away, RSI at the current or previous bar (per confirmation setting) is lower than pivot RSI and close is higher than pivot close (regular), or RSI is higher and close is lower (hidden), with both RSI and close staying below their straight lines between endpoints
Long: WaveTrend fast crosses above WaveTrend slow AND WaveTrend slow <= oversold threshold
Short: WaveTrend fast crosses below WaveTrend slow AND WaveTrend slow >= overbought threshold
Long: WaveTrend fast crosses above WaveTrend slow
Short: WaveTrend fast crosses below WaveTrend slow
Long: confirmed fractal low of WaveTrend slow, WaveTrend slow at pivot <= primary bullish divergence threshold, low at pivot < low at previous confirmed fractal low, and WaveTrend slow at pivot > WaveTrend slow at previous confirmed fractal low
Long: confirmed fractal low of WaveTrend slow, WaveTrend slow at pivot <= secondary bullish divergence threshold, low at pivot < low at previous confirmed fractal low, and WaveTrend slow at pivot > WaveTrend slow at previous confirmed fractal low
Short: confirmed fractal high of WaveTrend slow, WaveTrend slow at pivot >= primary bearish divergence threshold, high at pivot > high at previous confirmed fractal high, and WaveTrend slow at pivot < WaveTrend slow at previous confirmed fractal high
Short: confirmed fractal high of WaveTrend slow, WaveTrend slow at pivot >= secondary bearish divergence threshold, high at pivot > high at previous confirmed fractal high, and WaveTrend slow at pivot < WaveTrend slow at previous confirmed fractal high
Long: confirmed fractal low of WaveTrend slow, low at pivot > low at previous confirmed fractal low, and WaveTrend slow at pivot < WaveTrend slow at previous confirmed fractal low
Long: confirmed fractal low of RSI(RSI source, lookback), RSI at pivot <= bullish RSI divergence threshold, low at pivot < low at previous confirmed fractal low, and RSI at pivot > RSI at previous confirmed fractal low
Long: confirmed fractal low of RSI(RSI source, lookback), low at pivot > low at previous confirmed fractal low, and RSI at pivot < RSI at previous confirmed fractal low
Long: confirmed fractal low of Stochastic RSI K, low at pivot < low at previous confirmed fractal low, and Stochastic RSI K at pivot > its value at previous confirmed fractal low
Long: Realtime bullish RSI divergence
Short: confirmed fractal high of WaveTrend slow, high at pivot < high at previous confirmed fractal high, and WaveTrend slow at pivot > WaveTrend slow at previous confirmed fractal high
Short: confirmed fractal high of RSI(RSI source, lookback), RSI at pivot >= bearish RSI divergence threshold, high at pivot > high at previous confirmed fractal high, and RSI at pivot < RSI at previous confirmed fractal high
Short: confirmed fractal high of RSI(RSI source, lookback), high at pivot < high at previous confirmed fractal high, and RSI at pivot > RSI at previous confirmed fractal high
Short: confirmed fractal high of Stochastic RSI K, high at pivot > high at previous confirmed fractal high, and Stochastic RSI K at pivot < its value at previous confirmed fractal high
Short: Realtime bearish RSI divergence
Long: (primary regular bullish WaveTrend divergence OR regular bullish RSI divergence) AND previous WaveTrend fractal low <= deepest oversold threshold AND WaveTrend slow > deepest oversold threshold AND previous WaveTrend fractal low - WaveTrend slow <= recovery margin AND RSI at the latest WaveTrend fractal low < bullish RSI threshold
Long: Money flow > bullish money-flow threshold AND WaveTrend slow < bullish WaveTrend threshold AND WaveTrend fast crosses above WaveTrend slow AND WaveTrend gap(T1) > bullish gap threshold
Short: Money flow < bearish money-flow threshold AND WaveTrend slow > bearish WaveTrend threshold AND WaveTrend fast crosses below WaveTrend slow AND WaveTrend gap(T1) < bearish gap threshold
Long: WaveTrend slow <= bullish diamond threshold AND WaveTrend fast crosses above WaveTrend slow AND Heikin-Ashi close > open on both T1 and T2, sampled on chart bars from the still-forming T1 and T2 candles
Short: WaveTrend slow >= bearish diamond threshold AND WaveTrend fast crosses below WaveTrend slow AND Heikin-Ashi close < open on both T1 and T2, sampled on chart bars from the still-forming T1 and T2 candles