Calculation: Ichimoku lines = tenkan is the midpoint of the highest high and lowest low over a short lookback; kijun is the same midpoint over a longer lookback; span A is their average; span B is the midpoint over a still longer lookback. The displayed cloud boundaries are the maximum and minimum of spans A and B calculated a displacement number of bars ago.
Calculation: Anchored VWAP = cumulative sum of typical price times volume divided by cumulative volume, starting at a selected anchor datetime; typical price is (high + low + close) / 3.
Calculation: Confirmed alternating anchors = pivot highs and lows confirmed after the specified right-side bars. Append a pivot of the opposite type; replace the latest anchor with a same-type pivot only if it is at least as extreme. If a high and low confirm together, choose the type opposite the latest anchor; if there is no anchor, choose the pivot farther from the pivot bar's close, choosing the high on a tie.
Calculation: Pending double pattern = when the latest three anchors change, store a high-low-high pattern if the two highs differ by at most a multiple of ATR at the second high's bar and the middle low is below both highs; store a low-high-low pattern analogously. Each type remains pending until confirmed or invalidated, and a newer valid pattern of the same type replaces it. Invalidate a pending top when close exceeds the higher stored peak plus the current tolerance, or a pending bottom when close falls below the lower stored valley minus the current tolerance; current tolerance uses ATR shifted back by the pivot confirmation delay. Test confirmation before invalidation on each bar.
Calculation: Pitchfork median = line through the oldest of the latest three alternating anchors and the midpoint in time and price of the other two anchors, evaluated at the current bar.
Calculation: Approximate value area = divide the highest-high to lowest-low range over a lookback into equal price bins. Allocate each bar's volume among overlapping bins in proportion to its high-low overlap; allocate a zero-range bar's volume to its close's bin. Starting from the highest-volume bin, expand toward the larger-volume adjacent bin, choosing the upper bin on a tie, until a selected fraction of total volume is included. The lower and upper edges of the included bins are the value-area low and high.
Long: Close > displayed cloud upper boundary.
Short: Close < displayed cloud lower boundary.
Long: Tenkan > kijun.
Short: Tenkan < kijun.
Long: Span A >= span B.
Short: Span A < span B.
Long: Close >= anchored VWAP.
Short: Close < anchored VWAP.
Long: Close > pitchfork median.
Short: Close <= pitchfork median.
Long: Close < value-area low.
Short: Close > value-area high.
Long: A double bottom is pending AND close crosses above its stored neckline.
Short: A double top is pending AND close crosses below its stored neckline.