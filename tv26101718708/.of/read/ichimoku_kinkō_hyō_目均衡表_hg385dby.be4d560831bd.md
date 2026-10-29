Calculation: Price source = a selected OHLC-derived source, optionally smoothed with a four-bar symmetrically weighted moving average; alternatives are (open + close + 3 × (high + low)) / 8, close + high + low − 2 × open, (close + 5 × (high + low) − 7 × open) / 4, (open + close + 5 × (high + low)) / 12, high if close > open otherwise low, or high if OHLC4 > Heikin-Ashi open otherwise low. Heikin-Ashi open starts at (open + close) / 2 and subsequently equals the average of its previous value and previous OHLC4.
Calculation: Volume oscillator = one of: average signed volume over a lookback, with sign determined by close versus open; cumulative signed volume with sign determined by close change; fast EMA minus slow EMA of volume multiplied by a positive scale when close rises and a negative scale otherwise; fast EMA minus slow EMA of OBV, price-volume trend, or cumulative candle-volume delta; or volume zone oscillator. Candle-volume delta is volume times half the ratio of total wick length plus twice the body length when the candle rises, or total wick length plus twice the body length with a negative sign when it falls, divided by total candle range; use half the volume when the range is zero.
Calculation: Adaptive length = independently maintain a floating length for each Ichimoku component, initialized to the midpoint of its minimum and maximum. If at least one component filter is enabled and every enabled filter holds, multiply by its smoothing factor and floor at the minimum; otherwise multiply by 2 minus that factor and cap at the maximum. Truncate to an integer. The optional filters are its selected volume oscillator above the volume threshold, fast ATR above slow ATR, and price source above the highest high of a lookback ending one lookback ago. Alternatively use fixed component lengths.
Calculation: Ichimoku lines = for each of the shorter conversion and longer base lengths, average the Donchian midpoint over that length and the Donchian midpoint over the length divided by a reactivity divisor, truncated and floored at one. Leading span A is their average; leading span B is the Donchian midpoint over its longer length. Present cloud bounds are the maximum and minimum of the two leading spans from projection offset minus one bars ago. Lag offset is either a fixed offset or the adaptive lagging length.
Calculation: Trend strength = EMA of 100 × absolute difference between positive and negative directional indicators divided by their sum, or zero when their sum is zero. Each directional indicator is 100 × EMA of its directional movement divided by EMA of true range, or zero when that denominator is zero. Positive movement is max(high − previous high, 0) when it exceeds previous low − low, otherwise zero; negative movement is max(previous low − low, 0) when it exceeds high − previous high, otherwise zero.
Calculation: Bull and bear setup = respectively the conversion line equals the base line after being below or above it on the preceding bar, OR at least one directional filter is enabled and all enabled directional filters hold. Bull filters are volume oscillator > threshold, fast ATR > slow ATR, conversion > base, price source > price source at lag offset minus one, price source > price source at lag offset, price source > present cloud top, price source > conversion, and price source > highest high of a lookback ending one lookback ago. Bear filters use volume oscillator < the same positive threshold, fast ATR > slow ATR, conversion < base, price source < each respective lagged price, price source < present cloud top, price source < conversion, and price source < lowest low of a lookback ending one lookback ago. When the optional consolidation filter is enabled, also require trend strength >= its threshold OR present cloud thickness as a percentage of the larger absolute cloud bound >= its threshold.
Calculation: Regime = initially neutral; after the warm-up equal to the maximum component maximum length and projection offset, a newly true bear setup changes a nonbear regime to bear; then a newly true bull setup changes a nonbull regime to bull. A setup is newly true when it is true and was false on the preceding bar.
Long: Regime changes to bull.
Short: Regime changes to bear.
Long: Close > conversion line AND close > base line.
Short: Close < conversion line AND close < base line.
Long: Close > present cloud top.
Short: Close < present cloud bottom.
Long: Leading span A > leading span B.
Short: Leading span A < leading span B.
Long: Count of close > present cloud top, conversion > base, close > conversion, price source > price source at lag offset, and price source > highest high of a lookback ending one lookback ago > count of their bearish counterparts.
Short: Count of close < present cloud bottom, conversion < base, close < conversion, price source < price source at lag offset, and price source < lowest low of a lookback ending one lookback ago > count of their bullish counterparts.
Long: Price source > highest high of a lookback ending one lookback ago.
Short: Price source < lowest low of a lookback ending one lookback ago.
Long: Close > conversion line OR close > base line.
Short: Close <= conversion line OR close <= base line.
Long: Conversion line > base line.
Short: Conversion line < base line.
Long: Conversion line > previous conversion line OR base line > previous base line.
Short: Conversion line < previous conversion line OR base line < previous base line.
Long: Close > high at lag offset minus one.
Short: Close < low at lag offset minus one.
Long: A confirmed pivot low has a lower low than the bars on both sides within the swing lookback; evaluate when the right-hand lookback has completed.
Short: A confirmed pivot high has a higher high than the bars on both sides within the swing lookback; evaluate when the right-hand lookback has completed.
Calculation: Swing sequence = confirmed pivot highs and lows in chronological order; replace consecutive highs with the higher high and consecutive lows with the lower low. If both are confirmed on one bar, process the high first. Let A through E be consecutive stored swing prices, let L = absolute difference between A and B, and require the elapsed bars between the first and last point to be at least a minimum wave duration.
Long: Swing sequence has A < B AND A + tolerance × L < C < B − tolerance × L AND D > B + tolerance × L.
Short: Swing sequence has A > B AND B + tolerance × L < C < A − tolerance × L AND D < B − tolerance × L.
Long: Swing sequence has absolute differences |A − C|, |C − E|, and |B − D| <= tolerance × L AND A and C have the same pivot type AND B and D have the same pivot type AND B < A.
Short: Swing sequence has absolute differences |A − C|, |C − E|, and |B − D| <= tolerance × L AND A and C have the same pivot type AND B and D have the same pivot type AND B > A.
Long: Swing sequence has a contracting or expanding four-point range AND its last point is a pivot high.
Short: Swing sequence has a contracting or expanding four-point range AND its last point is a pivot low.
Calculation: Contracting four-point range = |C − D| is between a lower and an upper fraction of |A − B| AND C and D are both within the inclusive A–B price range. Expanding four-point range = |C − D| exceeds a larger fraction of |A − B| AND both C and D lie outside the A–B price range.
Long: Swing sequence has |C − A| <= tolerance × L AND C is a pivot low.
Short: Swing sequence has |C − A| <= tolerance × L AND C is a pivot high.
Long: Swing sequence has B > A.
Short: Swing sequence has B <= A.