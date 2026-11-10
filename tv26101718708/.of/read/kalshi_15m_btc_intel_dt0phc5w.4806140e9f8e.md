Calculation: Buffer = the most recent fixed number of lower-timeframe closes and volumes, including the latest available bar, which may still be forming; when the chart timeframe equals the source timeframe, use the current chart bar. Evaluate decisions only when the buffer is full.
Calculation: Buffered EMA = EMA recomputed over the buffer, seeded with its first observation; use a shorter span and a longer span for the two close EMAs.
Calculation: EMA separation = (shorter-span close EMA - longer-span close EMA) / longer-span close EMA × 100.
Calculation: Window move = (latest close - the close at the beginning of the trailing window of lower-timeframe bars) / that beginning close × 100.
Calculation: Volume ratio = volume summed over the trailing window divided by the mean volume of the available consecutive, nonoverlapping preceding windows, up to a fixed baseline count; use zero if the baseline is unavailable or nonpositive.
Calculation: Resampled RSI = Wilder RSI of closes sampled at a fixed stride from the buffer, anchored on its newest close; seed average gains and losses with their initial simple averages and return the maximum RSI value if average loss is zero. The sampling interval is longer than the source timeframe and is anchored to the latest source bar, which may still be forming.
Calculation: Momentum = buffered EMA of consecutive lower-timeframe percentage close returns; acceleration = current momentum minus momentum at a fixed earlier source bar within the same buffered EMA series.
Calculation: Tick balance = sum of the signs of consecutive lower-timeframe close changes over a fixed trailing number of source bars.
Calculation: Directional votes = seven values, each +1, -1, or 0: EMA separation above its positive deadband or below its negative deadband; resampled RSI at or above its bullish threshold or at or below its bearish threshold; window move positive or negative when the volume ratio reaches its surge threshold and its baseline is positive; window move above its positive deadband or below its negative deadband; momentum above its positive deadband or below its negative deadband; acceleration above its positive deadband or below its negative deadband; and tick balance at or above its positive threshold or at or below its negative threshold. Each vote is zero otherwise. Bullish RSI takes precedence if its thresholds overlap.
Calculation: Bullish count and bearish count = the respective counts of positive and negative directional votes; momentum bullish count and momentum bearish count = the corresponding counts among the RSI, momentum, acceleration, and tick-balance votes.
Calculation: Uptrend = absolute window move at or above the strong-move threshold AND EMA separation × window move > 0 AND momentum bullish count > 0 AND momentum bearish count = 0 AND bullish count > bearish count.
Calculation: Downtrend = absolute window move at or above the strong-move threshold AND EMA separation × window move > 0 AND momentum bearish count > 0 AND momentum bullish count = 0 AND bearish count > bullish count.
Long: Shorter-span close EMA > longer-span close EMA.
Short: Shorter-span close EMA <= longer-span close EMA.
Long: Bullish count > bearish count.
Short: Bearish count > bullish count.
Long: Window move > 0.
Short: Window move < 0.
Long: Any directional vote > 0.
Short: Any directional vote < 0.
Long: Momentum bullish count > 0 AND momentum bearish count = 0.
Short: Momentum bearish count > 0 AND momentum bullish count = 0.
Long: Uptrend = true.
Short: Downtrend = true.