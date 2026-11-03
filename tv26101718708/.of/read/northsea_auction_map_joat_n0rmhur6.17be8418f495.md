Calculation: Anchor bars = either the most recent chart bars within a rolling lookback, or the most recent contiguous session within that lookback, including a completed session if the current bar is outside it; use the rolling lookback if no session bar is found.
Calculation: Bar delta = volume × (0.45 × close bias + 0.35 × wick bias + 0.20 × signed body ratio), where range = max(high − low, minimum price increment), close bias = 2 × (close − low) / range − 1, signed body ratio = |close − open| / range with negative sign if close < open, wick buy = min(open, close) − low + |close − open| if close > open, otherwise min(open, close) − low, wick sell = high − max(open, close) + |close − open| if close < open, otherwise high − max(open, close), and wick bias = (wick buy − wick sell) / (wick buy + wick sell), or zero if the denominator is effectively zero.
Calculation: Profile = divide the anchor high-to-low range into a specified number of rows, with row width = max((anchor high − anchor low) / number of rows, minimum price increment). Allocate each anchor bar's volume and delta to each row in proportion to the overlap of the bar's high-low range with that row divided by max(bar high − bar low, minimum price increment). Clamp each bar's delta / volume to [−1, 1], using zero if volume is effectively zero; allocated buy and sell volumes are allocated volume × (1 + delta / volume) / 2 and allocated volume × (1 − delta / volume) / 2. Sum allocations per row.
Calculation: Value area ratio = start at the highest-volume profile row, choosing the lowest row on a tie; repeatedly add the larger-volume adjacent row, choosing the upper row on a tie, until the accumulated volume reaches the specified fraction of total profile volume. Divide accumulated volume by total profile volume, using zero if the denominator is effectively zero.
Calculation: Balance = mean row volume / max(sample standard deviation of row volumes, minimum price increment), using zero if the denominator is effectively zero.
Calculation: Delta bias = sum of profile row deltas / total profile volume, using zero if the denominator is effectively zero.
Calculation: Normalized VWAP distance = (close − anchor VWAP) / max(anchor high − anchor low, minimum price increment), where anchor VWAP is the volume-weighted mean of (high + low + close) / 3 over anchor bars; use zero if the distance denominator is effectively zero.
Calculation: Range location = clamp((close − anchor low) / max(anchor high − anchor low, minimum price increment), 0, 1), using one-half if the denominator is effectively zero.
Long: total profile volume > 0 AND any profile row's buy volume >= its sell volume
Short: total profile volume > 0 AND any profile row's buy volume < its sell volume
Long: delta bias > positive bias threshold
Short: delta bias < negative bias threshold
Long: normalized VWAP distance < negative distance threshold
Short: normalized VWAP distance > positive distance threshold
Long: range location > upper location threshold
Short: range location < lower location threshold
Long: value area ratio >= upper value-area threshold
Short: value area ratio < lower value-area threshold
Long: balance >= upper balance threshold
Short: balance <= lower balance threshold