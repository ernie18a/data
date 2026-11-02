Calculation: Supertrend direction = the direction returned by the standard ATR-based Supertrend; calculate independently for the main trail and the impulse trail.
Calculation: Ratcheted moving-average trail = a selected moving average of close; initialize to that average, then on each bar use the maximum of the average and the previous trail when the main Supertrend is bullish, otherwise use their minimum.
Calculation: Bullish gap = low > high two bars ago AND previous close > previous low + previous ATR multiplied by a threshold; bearish gap = high < low two bars ago AND previous close < previous high - previous ATR multiplied by a threshold. Register each gap on the following bar, with bullish bounds [high two bars before the gap, low at the gap] and bearish bounds [high at the gap, low two bars before the gap]. Maintain gaps separately by direction, newest first. Optionally remove overlaps: within each direction remove older gaps whose bounds strictly overlap or contain the newest gap; then remove bullish gaps that strictly overlap or contain the newest bearish gap, and bearish gaps that strictly overlap or contain the newest remaining bullish gap. A bullish gap becomes a breaker when the selected mitigation price is below its lower bound; a bearish gap becomes a breaker when it is above its upper bound. The mitigation price is either the lower body edge for bullish and upper body edge for bearish gaps, the low for bullish and high for bearish gaps, or the low for bullish and high for bearish gaps compared with the gap midpoint. In gap-only mode remove a gap on mitigation; in breaker mode retain it until the opposite body edge or wick crosses the opposite bound, or the opposite wick crosses the midpoint, according to the selected mitigation method. Process mitigation and optional overlap removal before evaluating raids. A gap can be raided once while unbroken.
Calculation: Confirmed pivot high or low = a high or low at the center of a symmetric lookback window, confirmed only after the specified number of bars on its right. For structure, retain the latest confirmed high and low separately; replace the corresponding level on each new pivot and allow each level to break once.
Calculation: Target levels = on each main Supertrend reversal, store the signal close and the absolute difference between that close and the main Supertrend value. For the signal direction, place two targets at the stored close plus or minus that difference times two ordered target multipliers. When the farther target is reached, increase both multipliers by a fixed increment and create a new pair from the same stored close and difference; reset on the next main Supertrend reversal.
Long: Main Supertrend direction changes from bearish to bullish.
Short: Main Supertrend direction changes from bullish to bearish.
Long: Impulse Supertrend direction changes from bearish to bullish.
Short: Impulse Supertrend direction changes from bullish to bearish.
Long: Close > ratcheted moving-average trail.
Short: Close <= ratcheted moving-average trail.
Long: A bullish gap is registered.
Short: A bearish gap is registered.
Short: An active bullish gap becomes a breaker in breaker mode.
Long: An active bearish gap becomes a breaker in breaker mode.
Long: Low < upper bound of an unbroken, unraided bullish gap AND close > that upper bound.
Short: High > lower bound of an unbroken, unraided bearish gap AND close < that lower bound.
Long: Low > high two bars ago AND previous close > high two bars ago AND close two bars ago < open two bars ago.
Short: High < low two bars ago AND previous close < low two bars ago AND close two bars ago > open two bars ago.
Long: A pivot low is confirmed AND the current bar's lower wick > a configured fraction of its high-low range.
Short: A pivot high is confirmed AND the current bar's upper wick > a configured fraction of its high-low range.
Long: Close or high, according to the selected break method, > the latest unbroken confirmed structure pivot high.
Short: Close or low, according to the selected break method, < the latest unbroken confirmed structure pivot low.
Long: Low < the low of the last completed bar of any selected higher timeframe AND close > that low.
Short: High > the high of the last completed bar of any selected higher timeframe AND close < that high AND no selected higher-timeframe low is swept on the same bar.
Exit: long, high >= either current target for the latest bullish main Supertrend reversal.
Exit: short, low <= either current target for the latest bearish main Supertrend reversal.