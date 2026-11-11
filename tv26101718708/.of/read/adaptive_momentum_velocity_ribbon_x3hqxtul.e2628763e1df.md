Calculation: HMA = WMA(2 × WMA(close, round(length / 2)) − WMA(close, length), round(sqrt(length))).
Calculation: HMA velocity = current HMA − HMA a shared velocity lookback ago.
Long: Fast HMA velocity crosses above the signal threshold AND bars since the most recent long or short threshold-crossing signal are at least the cooldown.
Short: Fast HMA velocity crosses below the signal threshold AND bars since the most recent long or short threshold-crossing signal are at least the cooldown.
Long: Any of the fast, medium, or slow HMA velocities is > 0.
Short: Any of the fast, medium, or slow HMA velocities is <= 0.
Long: Fast HMA velocity > medium HMA velocity OR medium HMA velocity > slow HMA velocity.
Short: Fast HMA velocity <= medium HMA velocity OR medium HMA velocity <= slow HMA velocity.
Long: HMA velocity on either dashboard timeframe is > 0.
Short: HMA velocity on either dashboard timeframe is <= 0.
Calculation: The fast, medium, and slow chart HMAs use successively longer lengths. Both dashboard timeframes use the same HMA length and the shared velocity lookback; one dashboard timeframe is longer than the other. For a dashboard timeframe higher than the chart timeframe, use the last completed bar on historical chart bars and the still-forming bar in real time. For a lower dashboard timeframe, use its last available intrabar within the chart bar.