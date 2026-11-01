Calculation: Reconstructed signed volume = for each completed lower-timeframe bar within the chart bar, multiply its volume by a signed weight. Use the positive or negative strong weight when its close is respectively above or below its open; otherwise use the same weights when its close is above or below the preceding lower-timeframe close within the chart bar; otherwise carry the preceding classification's sign with the mixed weight; otherwise use the mixed weight times ((close-low)-(high-close))/(high-low) if the absolute value of that ratio exceeds a threshold, or zero. For the first lower-timeframe bar, initialize the preceding close to its own close and the preceding sign to zero. Sum positive signed volumes as buy volume, absolute negative signed volumes as sell volume, and all signed volumes as delta. A chart bar has valid reconstructed data when the fraction of valid classified lower-timeframe bars meets a threshold.
Calculation: Cumulative delta = sum of delta on valid chart bars, reset at a configurable session boundary, higher-timeframe boundary, time of day, Supertrend direction change, or never.
Calculation: Smoothed imbalance = (buy volume - sell volume)/(buy volume + sell volume), or zero when the denominator is zero; smooth either with an SMA or recursively on valid bars using alpha = slow alpha + (fast alpha - slow alpha) times Kaufman efficiency ratio. Imbalance acceleration = smoothed imbalance minus its value a configurable number of bars ago.
Calculation: Footprint bins = partition the chart bar's price range into a configurable number of bins, using either equal bar-range widths or a configurable percentage of close. Allocate each valid lower-timeframe bar's absolute signed volume to its buy or sell bin according to the bin containing its (high + low + close)/3, clamped to the first or last bin. The strongest imbalance is the largest buy or sell share of its bin's total volume, scanning bins from low to high and retaining the first on ties.
Calculation: Footprint pattern = compare the share of total bin volume in the upper half of bins with upper and lower thresholds. Assign positive strong or mild scores when delta is positive and the upper-half share reaches the corresponding strong or mild upper threshold; assign negative strong or mild scores when delta is negative and the share is at or below the corresponding strong or mild lower threshold. Also assign a positive mild score when delta is positive and the share is at or below the mild lower threshold, or a negative mild score when delta is negative and the share reaches the mild upper threshold; otherwise assign zero. The strong upper threshold exceeds the mild upper threshold, and the strong lower threshold is below the mild lower threshold.
Calculation: Regime score = weighted sum of smoothed imbalance, delta divided by chart-bar volume clipped to [-1,1], cumulative delta divided by a multiple of average volume and then transformed as x/(1+abs(x)), imbalance acceleration multiplied by a scaling factor and clipped to [-1,1], the current session's accumulated market-on-close-window delta divided by its accumulated volume clipped to [-1,1], and half the footprint pattern score. Use zero for unavailable components. The market-on-close accumulation resets at each session boundary and retains its last calculated value after the window closes until the next reset.
Calculation: Recent pivot low or high = the most recently confirmed pivot low or high, respectively, whose confirmation occurred within a configurable lookback ending on the preceding chart bar; pivot confirmation requires configurable numbers of left and right bars.
Long: delta > 0
Short: delta < 0
Long: cumulative delta > 0
Short: cumulative delta < 0
Long: smoothed imbalance > positive threshold
Short: smoothed imbalance < negative threshold
Long: imbalance acceleration > positive threshold
Short: imbalance acceleration < negative threshold
Long: buy volume / (buy volume + sell volume) > upper threshold AND buy volume + sell volume > 0
Short: buy volume / (buy volume + sell volume) < lower threshold AND buy volume + sell volume > 0
Long: footprint pattern > 0
Short: footprint pattern < 0
Long: strongest footprint imbalance is buy-dominant AND its buy share >= imbalance threshold
Short: strongest footprint imbalance is sell-dominant AND its sell share >= imbalance threshold
Long: valid reconstructed data AND close < open AND delta > 0
Short: valid reconstructed data AND close > open AND delta < 0
Long: regime score >= bullish threshold
Short: regime score <= bearish threshold
Long: low < recent pivot low AND close > recent pivot low AND close - low >= (recent pivot low - low) times (1 + reclaim fraction) AND volume > SMA(volume) times volume multiplier
Short: high > recent pivot high AND close < recent pivot high AND high - close >= (high - recent pivot high) times (1 + reclaim fraction) AND volume > SMA(volume) times volume multiplier