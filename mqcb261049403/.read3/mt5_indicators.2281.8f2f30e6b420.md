Calculation: Volatility Stop = prior close initially; otherwise prior stop if close equals prior stop, the minimum of prior stop and close plus distance if the prior and current closes are below prior stop, the maximum of prior stop and close minus distance if both are above prior stop, close minus distance if current close is above prior stop, and close plus distance otherwise; distance is either a fixed price distance or a factor times EMA(ATR(lookback), smoothing lookback)
Long: close > Volatility Stop
Short: close < Volatility Stop
Long: close crosses above Volatility Stop
Short: close crosses below Volatility Stop
Long: on chart bars where a T1 bar changes, close(T1, still-forming bar) > Volatility Stop(T1, still-forming bar)
Short: on chart bars where a T1 bar changes, close(T1, still-forming bar) < Volatility Stop(T1, still-forming bar)