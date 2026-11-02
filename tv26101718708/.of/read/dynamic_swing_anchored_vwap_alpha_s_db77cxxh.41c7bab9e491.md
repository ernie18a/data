Calculation: Swing locations = Initialize the latest high and low bar indices to the first bar. On each bar, update the high index and high value when the current high is the highest high in the swing lookback; update the low index and low value when the current low is the lowest low in that lookback. Swing direction is bullish when the high index is greater than the low index, and bearish otherwise.
Calculation: Previous swing extreme = Initially undefined; after each swing direction change, set it to the preceding bar's stored swing high when the new direction is bullish, or the preceding bar's stored swing low when the new direction is bearish. Evaluate swing-point comparisons before updating it.
Calculation: Dynamic swing-anchored VWAP = Initialize price-volume and volume accumulators to hlc3 times volume and volume on the first bar. Tracking speed is the base speed, optionally divided by (ATR divided by its Wilder moving average over the same ATR period) raised to the volatility sensitivity; use a ratio of 1 when the average ATR is not positive. Clamp speed to the script's minimum and maximum tracking limits and round it; alpha is 1 minus exp(-ln(2) divided by max(1, rounded speed)). On a swing direction change, reset the accumulators to anchor price times anchor-bar volume and anchor-bar volume, where the anchor is the latest swing low for a bullish change or latest swing high for a bearish change; use current volume if anchor-bar volume is unavailable or the anchor is outside the supported history. On every bar, including a reset bar, update each accumulator to (1 - alpha) times its prior or reset value plus alpha times the current hlc3 times volume or current volume, respectively. VWAP is the price-volume accumulator divided by the volume accumulator when the latter is positive.
Long: Swing direction is bullish.
Short: Swing direction is bearish.
Long: Close is above dynamic swing-anchored VWAP.
Short: Close is below dynamic swing-anchored VWAP.
Long: Close crosses above dynamic swing-anchored VWAP.
Short: Close crosses below dynamic swing-anchored VWAP.
Long: Swing direction changes to bullish.
Short: Swing direction changes to bearish.
Long: Swing direction changes to bullish AND the latest swing low is greater than the previous swing extreme.
Short: Swing direction changes to bullish AND the latest swing low is less than the previous swing extreme.
Long: Swing direction changes to bearish AND the latest swing high is greater than the previous swing extreme.
Short: Swing direction changes to bearish AND the latest swing high is less than the previous swing extreme.
Long: Close is above dynamic swing-anchored VWAP AND swing direction is bullish AND 100 times (close minus dynamic swing-anchored VWAP) divided by dynamic swing-anchored VWAP is greater than the strong-distance threshold AND dynamic swing-anchored VWAP is positive.
Short: Close is below dynamic swing-anchored VWAP AND swing direction is bearish AND 100 times (close minus dynamic swing-anchored VWAP) divided by dynamic swing-anchored VWAP is less than the negative strong-distance threshold AND dynamic swing-anchored VWAP is positive.