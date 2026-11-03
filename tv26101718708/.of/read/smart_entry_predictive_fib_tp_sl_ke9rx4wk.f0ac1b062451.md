Calculation: Structure = for each of three chart-timeframe lookbacks, longest, intermediate and shortest, take the highest high H, lowest low L and range R = H - L, including the current bar.
Calculation: Long zone = [H - 0.786 × R, H - 0.618 × R]; short zone = [H - 0.382 × R, H - 0.236 × R]. Calculate each for all three structures.
Calculation: Selected zone = the intersection of all three same-side zones if its lower bound is strictly below its upper bound; otherwise the first valid pairwise intersection in this order: longest and intermediate, longest and shortest, intermediate and shortest; otherwise the longest-lookback zone. An intersection's lower bound is the maximum lower bound and its upper bound is the minimum upper bound.
Calculation: Volume point of control = on the last dataset bar only, if the longest-lookback range is positive, divide that range into equal price buckets; sum the full volume of every longest-lookback bar whose high-low interval intersects each bucket, including its boundaries. Select the midpoint of the first bucket with the greatest positive volume sum, or the range midpoint if all sums are zero. On historical bars it is unavailable.
Calculation: Proposed long entry = volume point of control if available and inside the selected long zone, otherwise the selected long zone's lower bound. Proposed short entry = volume point of control if available and inside the selected short zone, otherwise the selected short zone's upper bound.
Calculation: Long reward-to-risk = absolute difference between proposed long entry and the longest-lookback H - 0.236 × R, divided by the absolute difference between proposed long entry and proposed long entry reduced by the stop buffer percentage. Short reward-to-risk = absolute difference between proposed short entry and the longest-lookback H - 0.786 × R, divided by the absolute difference between proposed short entry and proposed short entry increased by the stop buffer percentage. Round each ratio to one decimal; use zero if its denominator is zero.
Long: Close >= selected long zone lower bound AND close <= selected long zone upper bound AND long reward-to-risk >= minimum reward-to-risk.
Short: Close >= selected short zone lower bound AND close <= selected short zone upper bound AND short reward-to-risk >= minimum reward-to-risk.
Long: RSI <= lower RSI threshold.
Short: RSI >= upper RSI threshold.
Long: Shorter-period EMA of close > longer-period EMA of close.
Short: Shorter-period EMA of close <= longer-period EMA of close.
Long: Close > SMA of close.
Short: Close <= SMA of close.