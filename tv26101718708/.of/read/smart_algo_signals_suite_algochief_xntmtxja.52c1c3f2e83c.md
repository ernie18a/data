Calculation: Swing direction = initialize to neutral; calculate efficiency as abs(close - close N bars ago) / max(sum of absolute close-to-close changes over N bars, epsilon). Calculate alpha as clamp(sensitivity × (efficiency × (fast smoothing constant - slow smoothing constant) + slow smoothing constant)^2, minimum alpha, maximum alpha), where slow smoothing constant = 2 / (N + 1) and the fast smoothing constant is larger. Initialize the baseline to close and update it to previous baseline + alpha × (close - previous baseline). Set direction long when close > baseline + ATR × band factor / max(sensitivity, minimum sensitivity), short when close < baseline - ATR × band factor / max(sensitivity, minimum sensitivity), and otherwise retain the previous direction.
Calculation: Scalping direction = initialize to neutral; set long when the shorter close EMA > the longer close EMA AND RSI > its midpoint, set short when the shorter close EMA < the longer close EMA AND RSI < its midpoint, and otherwise retain the previous direction.
Calculation: Engine direction = swing direction or scalping direction according to the selected engine mode.
Calculation: Raw long signal = in trend mode, engine direction = long AND previous engine direction != long; in reversal mode, (low <= close SMA - deviation multiplier × close standard deviation OR RSI < lower threshold) AND close > open AND close > previous high AND the same condition was false on the previous bar.
Calculation: Raw short signal = in trend mode, engine direction = short AND previous engine direction != short; in reversal mode, (high >= close SMA + deviation multiplier × close standard deviation OR RSI > upper threshold) AND close < open AND close < previous low AND the same condition was false on the previous bar.
Calculation: Trailing bands and direction = calculate center as VWMA of (high + low + close) / 3 and width as ATR with the same lookback × width multiplier. Initialize direction to long. While previously long, set lower band to max(previous lower band, center - width), using center - width if the previous band is unavailable, and upper band to lower band + width; if close < lower band, set direction short, upper band to center + width, and lower band to center. While previously short, set upper band to min(previous upper band, center + width), using center + width if the previous band is unavailable, and lower band to upper band - width; if close > upper band, set direction long, lower band to center - width, and upper band to center.
Calculation: Stepped trend level = initialize to EMA of (high + low) / 2; update to that EMA when its absolute change over a lookback is > ATR with the EMA lookback × threshold; otherwise retain the previous level.
Calculation: Bias momentum = change over a smoothing lookback in the WMA of close.
Calculation: Trend score = weighted sum of (100 - choppiness), efficiency ratio × 100, and ADX. Choppiness = 100 × log10(sum of true range over the classifier lookback / (highest high - lowest low over that lookback)) / log10(classifier lookback), or a neutral fallback if the range is zero. Efficiency ratio = abs(close - close at the classifier lookback) / sum of absolute close changes over that lookback, or zero if the denominator is zero.
Calculation: Directional vote count = count enabled components whose direction matches: engine direction; trailing-band direction; close >= stepped trend level for long or close < it for short; bias momentum >= zero for long or < zero for short; close SMA minus ATR × inner-band multiplier >= low for long only if high < close SMA plus ATR × inner-band multiplier, or high >= the upper inner band for short; trend score >= threshold AND close >= its classifier-lookback EMA for long or close < it for short.
Calculation: Trade levels = on each raw signal, set entry to close and freeze stop distance and each progressively ordered target distance as either entry-bar ATR × its respective multiplier or entry price × its respective percentage. For a long, stop = entry - stop distance and targets = entry + target distances; for a short, stop = entry + stop distance and targets = entry - target distances. Replace levels on each new raw signal.
Long: Raw long signal.
Short: Raw short signal.
Long: Trailing-band direction = long AND low <= upper band AND low >= lower band - width × retest tolerance AND close > open AND raw long signal = false AND bars since the previous long retest signal > cooldown.
Short: Trailing-band direction = short AND high >= lower band AND high <= upper band + width × retest tolerance AND close < open AND raw short signal = false AND bars since the previous short retest signal > cooldown.
Long: Engine direction = long.
Short: Engine direction = short.
Long: Trailing-band direction = long.
Short: Trailing-band direction = short.
Long: Close >= stepped trend level.
Short: Close < stepped trend level.
Long: Bias momentum >= zero.
Short: Bias momentum < zero.
Long: Low <= close SMA - ATR with the same lookback × inner-band multiplier AND high < close SMA + ATR × inner-band multiplier.
Short: High >= close SMA + ATR with the same lookback × inner-band multiplier.
Long: Trend score >= threshold AND close >= classifier-lookback EMA of close.
Short: Trend score >= threshold AND close < classifier-lookback EMA of close.
Long: Long directional vote count > short directional vote count.
Short: Short directional vote count > long directional vote count.
Long: Close >= open.
Short: Close < open.
Exit: long, the most recent raw signal direction = long AND no momentum exit has fired since that signal AND bars since the last momentum exit of either side > cooldown AND (RSI crosses below an upper threshold OR (high = highest high over the exit lookback AND close < open AND high - close > (close - low) × wick multiplier)).
Exit: short, the most recent raw signal direction = short AND no momentum exit has fired since that signal AND bars since the last momentum exit of either side > cooldown AND (RSI crosses above a lower threshold OR (low = lowest low over the exit lookback AND close > open AND close - low > (high - close) × wick multiplier)).
Exit: long, bar is after the raw entry signal AND (low <= frozen stop OR high >= selected final target).
Exit: short, bar is after the raw entry signal AND (high >= frozen stop OR low <= selected final target).
Exit: long, high >= any frozen target AND previous high < that target, OR low <= frozen stop AND previous low > that stop.
Exit: short, low <= any frozen target AND previous low > that target, OR high >= frozen stop AND previous high < that stop.