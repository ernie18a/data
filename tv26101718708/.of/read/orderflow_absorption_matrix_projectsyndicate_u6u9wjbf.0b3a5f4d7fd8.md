Calculation: Intrabar delta = sum of lower-timeframe bar volume multiplied by the sign of close minus open, over the lower-timeframe bars within the chart bar, including the still-forming lower-timeframe bar. If none are available, delta is zero.
Calculation: Side classification = configurable candle direction, delta direction, or agreement of both; candle buy means close >= open and candle sell means close < open; delta buy means intrabar delta > 0 and delta sell means intrabar delta < 0. If lower-timeframe bars are unavailable, use candle direction.
Calculation: Print = volume and absolute intrabar delta are each tested against their own linear-interpolated percentile over short, medium, and long chart-bar lookbacks, including the current bar. A test passes when the value is >= the percentile in a configurable number of windows. Test three increasing percentile tiers separately; assign each measure its highest passing tier. Combine the volume and delta tiers using the configured volume-only, delta-only, both, or either rule, requiring both measures to meet at least the same tier for the both rule. If lower-timeframe bars are unavailable, use volume only. A print exists if any tier passes.
Calculation: Profile = divide the rolling chart-bar range from lowest low to highest high into equal price bins. Assign each bar's volume, intrabar delta, and absorption to the bin containing its (high + low + close) / 3, clamped to the profile range. Absorption is the sum of lower-timeframe volume for rising intrabars closing in the chart bar's upper wick and falling intrabars closing in its lower wick. Include available lower-timeframe bars within each chart bar, including a still-forming bar. Count a touch in every bin intersected by each chart bar. Count an upper or lower rejection in the bin containing that bar's high or low when the corresponding wick exceeds a configurable fraction of its range. Record each bin's age as the number of bars since its most recent touch, or the effective profile lookback if untouched.
Calculation: Zone = an interior profile bin whose selected source is > the preceding bin's source, >= the following bin's source, and > 0. Source is configurable as bin volume divided by maximum bin volume, bin absorption divided by maximum bin absorption, or their equal-weight average; a zero maximum gives a zero component. Zone strength is the normalized weighted average of relative bin volume, relative bin absorption, touches capped at a configurable normalization count, rejections divided by maximum bin rejections, and one minus touch age divided by effective profile lookback; zero denominators give zero components. Retain zones at or above the configured minimum strength and at or above the strength of the configured Nth strongest qualifying zone, if more than N qualify; ties are retained. Zone midpoint is the mean of its price boundaries.
Calculation: Absorption bias = (profile absorption in bins with midpoint < close minus profile absorption in bins with midpoint >= close) / max(total profile absorption, 1).
Calculation: Flow pressure = weighted sum of profile volume imbalance, rolling delta bias, absorption bias, and the direction of the latest print. Profile volume imbalance is (volume of bars with close >= open minus volume of bars with close < open) / total profile volume, or zero if total volume is zero. Rolling delta bias is the sum of intrabar delta divided by max(sum of absolute intrabar delta, 1), clamped to [-1, 1], over the profile lookback. Latest print direction is +1 for a buy-classified print, -1 for a sell-classified print, and 0 for a mixed print or before any print.
Calculation: Higher-timeframe flow = EMA of signed volume divided by max(EMA of volume, 1), with equal EMA lengths; signed volume is positive when close >= open and negative otherwise. Calculate separately on each configured higher timeframe using its last completed bar.
Long: Side classification is buy.
Short: Side classification is sell.
Long: Print exists AND side classification is buy.
Short: Print exists AND side classification is sell.
Long: Profile bin delta > 0.
Short: Profile bin delta < 0.
Long: Rolling sum of intrabar delta >= 0.
Short: Rolling sum of intrabar delta < 0.
Long: Profile volume imbalance >= 0.
Short: Profile volume imbalance < 0.
Long: Close >= point of control, where point of control is the midpoint of the first highest-volume profile bin.
Short: Close < point of control, where point of control is the midpoint of the first highest-volume profile bin.
Long: Zone midpoint < close.
Short: Zone midpoint >= close.
Long: Absorption bias > positive threshold.
Short: Absorption bias < negative threshold of equal magnitude.
Long: Flow pressure > positive threshold.
Short: Flow pressure < negative threshold of equal magnitude.
Long: Higher-timeframe flow > positive threshold.
Short: Higher-timeframe flow < negative threshold of equal magnitude.