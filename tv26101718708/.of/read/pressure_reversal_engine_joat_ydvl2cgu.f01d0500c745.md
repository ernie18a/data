Calculation: Candle range = max(high − low, minimum price increment); the minimum price increment is a parameter.
Calculation: Buy share = clamp(0.16 + 0.44 × (close − low) / candle range + 0.22 × abs(close − open) / candle range + 0.18 × indicator(close >= open), 0.05, 0.95); pressure = 2 × buy share − 1.
Calculation: Volume ratio = volume / SMA(volume) when that SMA > 0, otherwise 1.
Calculation: Lower wick = min(open, close) − low; upper wick = high − max(open, close).
Calculation: Demand absorption = pressure < −pressure gate AND close > open AND lower wick > upper wick AND abs(close − open) / candle range < body threshold AND volume ratio > participation threshold. Supply absorption = pressure > pressure gate AND close < open AND upper wick > lower wick AND abs(close − open) / candle range < body threshold AND volume ratio > participation threshold.
Calculation: Pressure profile = divide the range from the lowest low to the highest high over the profile lookback, including the current bar, into equal rows; use max(range, minimum price increment) as the range. Assign each bar's volume to the row containing its (high + low + close) / 3, clamping the row index to the available rows. POC is the midpoint of the highest-volume row, choosing the lowest row on ties. Starting at that row, add the higher-volume adjacent row until the accumulated volume reaches the value-area fraction of total volume or all rows are included; choose the lower adjacent row on ties. Value-area low and high are the bottom and top boundaries of the included rows. Profile skew = sum(volume × (2 × buy share − 1)) / sum(volume), or 0 when total volume is 0.
Calculation: Swing high and swing low = the most recently confirmed pivot high and pivot low, respectively, using configured left and right bar counts; update each reference when its pivot is confirmed.
Calculation: Reclaim high = close > swing high AND previous close <= current swing high AND pressure > pressure gate. Reject high = high > swing high AND close < swing high AND pressure < −pressure gate. Reclaim low = close < swing low AND previous close >= current swing low AND pressure < −pressure gate. Reject low = low < swing low AND close > swing low AND pressure > pressure gate.
Long: On a completed bar, close > profile POC AND close > value-area low AND (demand absorption OR reject low OR reclaim high) AND profile skew > negative skew threshold AND (regime filter disabled OR shorter-period EMA of close > longer-period EMA of close) AND (no previous long or short setup OR bars since the most recent long or short setup > cooldown).
Short: On a completed bar, close < profile POC AND close < value-area high AND (supply absorption OR reject high OR reclaim low) AND profile skew < positive skew threshold AND (regime filter disabled OR shorter-period EMA of close < longer-period EMA of close) AND (no previous long or short setup OR bars since the most recent long or short setup > cooldown).
Long: On a completed bar, demand absorption.
Short: On a completed bar, supply absorption.
Long: On a completed bar, close < open AND pressure > pressure gate AND supply absorption = false.
Short: On a completed bar, close > open AND pressure < −pressure gate AND demand absorption = false.
Long: Pressure > pressure gate.
Short: Pressure < −pressure gate.
Long: Shorter-period EMA of close > longer-period EMA of close.
Short: Shorter-period EMA of close < longer-period EMA of close.
Long: Profile skew >= 0.
Short: Profile skew < 0.
Long: Pressure > pressure gate AND volume ratio > stack volume threshold for at least the minimum stack length of consecutive bars.
Short: Pressure < −pressure gate AND volume ratio > stack volume threshold for at least the minimum stack length of consecutive bars.
Exit: long, on a completed bar, supply absorption OR (close < open AND pressure > pressure gate) OR close < shorter-period EMA of close OR reject high.
Exit: short, on a completed bar, demand absorption OR (close > open AND pressure < −pressure gate) OR close > shorter-period EMA of close OR reject low.