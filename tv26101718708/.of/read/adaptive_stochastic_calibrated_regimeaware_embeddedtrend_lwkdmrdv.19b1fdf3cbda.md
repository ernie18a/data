Calculation: Source = a selected price field or OHLC average, optionally replaced by its RSI and optionally passed through an Ehlers two-pole high-pass filter followed by a two-pole smoother.
Calculation: Oscillator = stochastic of Source using rolling high and low when Source is unfiltered price, otherwise using rolling Source extrema; use the midpoint when the range is zero. Optionally average stochastic values from shorter, standard, and longer lookbacks. Optionally set the lookback from a bounded multiple of the Ehlers homodyne dominant cycle. Smooth the result to obtain K and smooth K again to obtain D, using the selected SMA, Ehlers two-pole smoother, or Ehlers low-lag smoother. Optionally apply the inverse Fisher transform to each, rescaled to the stochastic range.
Calculation: Bands = upper and lower rolling, linearly interpolated percentiles of K; the upper percentile exceeds the lower percentile.
Calculation: Embedded up or down = K has remained at or above the upper band, or at or below the lower band, respectively, for at least a specified number of consecutive bars.
Calculation: Trend = ADX exceeds its threshold AND the efficiency ratio of Source exceeds its threshold. Range = Trend is false AND the volatility-cluster z-score does not exceed its threshold. Volatility-cluster intensity is the exponentially decayed prior intensity plus the absolute change in log close; its z-score uses a rolling mean and standard deviation.
Calculation: Cycle detrend = the Ehlers homodyne dominant-cycle detrended component of the weighted average of high-low midpoint; the dominant-cycle period is recursively smoothed and bounded.
Calculation: Trail = a CMO-scaled adaptive moving average of K with a percentage band. Optionally scale the band percentage by rolling K standard deviation and bound it. Trail the lower band upward while the average remains above its prior lower band, and trail the upper band downward while the average remains below its prior upper band. Switch direction when the average crosses the opposing prior band; select the lower band in the up direction and upper band in the down direction, adjust it by half the band percentage toward the average, and lag it by two bars.
Calculation: Confirmed oscillator pivot = a K high or low with the specified numbers of bars to its left and right; compare consecutive pivots of the same type and the price highs or lows at those pivot bars. Evaluate divergence when the later pivot is confirmed.
Calculation: Higher-timeframe bias = the sign of the higher-timeframe SMA-smoothed stochastic of close relative to its midpoint, using the last completed higher-timeframe bar.
Long: K is at or below the lower band.
Short: K is at or above the upper band.
Long: K is at or above the stochastic midpoint when momentum display is enabled.
Short: K is below the stochastic midpoint when momentum display is enabled.
Long: Embedded up.
Short: Embedded down.
Long: The adaptive moving average of K is above Trail.
Short: The adaptive moving average of K is at or below Trail.
Long: Trend AND close is above its regime EMA.
Short: Trend AND close is at or below its regime EMA.
Long: Higher-timeframe bias is positive.
Short: Higher-timeframe bias is negative.
Long: Range AND embedded down is false AND previous K is at or below its previous lower band AND K crosses above D AND, if the cycle-phase gate is enabled, cycle detrend is at or below zero AND is at or above its previous value AND, if the signal-to-noise gate is enabled, rolling standard deviation of cycle detrend divided by ATR is at or above its threshold.
Short: Range AND embedded up is false AND previous K is at or above its previous upper band AND K crosses below D AND, if the cycle-phase gate is enabled, cycle detrend is at or above zero AND is below its previous value AND, if the signal-to-noise gate is enabled, rolling standard deviation of cycle detrend divided by ATR is at or above its threshold.
Long: Trend AND close is above its regime EMA AND (the adaptive moving average of K crosses above Trail OR (the average is above Trail AND K crosses above D AND K is below the stochastic midpoint)) AND, if the higher-timeframe gate is enabled, higher-timeframe bias is nonnegative AND, if the signal-to-noise gate is enabled, rolling standard deviation of cycle detrend divided by ATR is at or above its threshold.
Short: Trend AND close is at or below its regime EMA AND (the adaptive moving average of K crosses below Trail OR (the average is at or below Trail AND K crosses below D AND K is above the stochastic midpoint)) AND, if the higher-timeframe gate is enabled, higher-timeframe bias is nonpositive AND, if the signal-to-noise gate is enabled, rolling standard deviation of cycle detrend divided by ATR is at or above its threshold.
Long: A confirmed K low pivot has a lower price low and a higher K value than the preceding confirmed K low pivot.
Short: A confirmed K high pivot has a higher price high and a lower K value than the preceding confirmed K high pivot.
Long: A confirmed K low pivot has a higher price low and a lower K value than the preceding confirmed K low pivot.
Short: A confirmed K high pivot has a lower price high and a higher K value than the preceding confirmed K high pivot.