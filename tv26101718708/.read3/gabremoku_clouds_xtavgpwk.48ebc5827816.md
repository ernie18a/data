Calculation: Typical price = mean(high, low, close)
Calculation: Volume-weighted equilibrium = sum(volume × typical price, equilibrium lookback) / sum(volume, equilibrium lookback), or typical price when the volume sum is zero
Calculation: Volume-weighted range = sum(volume × (high - low), equilibrium lookback) / sum(volume, equilibrium lookback), or high - low when the volume sum is zero
Calculation: Upper cloud band = volume-weighted equilibrium + cloud multiplier × volume-weighted range
Calculation: Lower cloud band = volume-weighted equilibrium - cloud multiplier × volume-weighted range
Calculation: Upper bubble band = volume-weighted equilibrium + bubble-band multiplier × volume-weighted range
Calculation: Lower bubble band = volume-weighted equilibrium - bubble-band multiplier × volume-weighted range
Calculation: Relative volume = volume / SMA(volume, volume-average lookback), or one when the SMA is zero
Calculation: High relative volume = relative volume >= high-volume threshold
Calculation: Volume velocity = relative volume - relative volume[volume-velocity lookback]
Calculation: Squeeze = (volume-weighted range - lowest(volume-weighted range, squeeze lookback)) / (highest(volume-weighted range, squeeze lookback) - lowest(volume-weighted range, squeeze lookback)) <= squeeze threshold, or zero when the highest and lowest are equal
Calculation: Equilibrium rising = volume-weighted equilibrium > volume-weighted equilibrium[slope lookback]
Calculation: Equilibrium falling = volume-weighted equilibrium < volume-weighted equilibrium[slope lookback]
Calculation: Adaptive cloud bullish = (VWMA(typical price, shorter adaptive-cloud lookback) + VWMA(typical price, longer adaptive-cloud lookback)) / two >= (highest(typical price, wider adaptive-cloud lookback) + lowest(typical price, wider adaptive-cloud lookback)) / two
Calculation: Contraction = abs(volume-weighted equilibrium - volume-weighted equilibrium[one bar less than the equilibrium lookback]) < volume-weighted range × flat-slope threshold
Calculation: Bullish cloud state = not Squeeze AND ((selected price source > Upper cloud band AND High relative volume) OR (selected price source > volume-weighted equilibrium AND Equilibrium rising))
Calculation: Bearish cloud state = not Squeeze AND ((selected price source < Lower cloud band AND High relative volume) OR (selected price source < volume-weighted equilibrium AND Equilibrium falling))
Calculation: Smoothed equilibrium = EMA(volume-weighted equilibrium, projection-smoothing lookback)
Calculation: Smoothed equilibrium slope = EMA((Smoothed equilibrium - Smoothed equilibrium[projection-slope lookback]) / projection-slope lookback, projection-slope-smoothing lookback)
Calculation: Projected equilibrium = Smoothed equilibrium + Smoothed equilibrium slope × projection-forward bars × projection damping
Calculation: Bull confidence count = number of true conditions among Bullish cloud state, Adaptive cloud bullish, and Projected equilibrium > Smoothed equilibrium
Calculation: Bear confidence count = number of true conditions among Bearish cloud state, not Adaptive cloud bullish, and Projected equilibrium < Smoothed equilibrium
Calculation: Confidence score = greater of Bull confidence count and Bear confidence count
Long: selected price source > Upper cloud band
Short: selected price source < Lower cloud band
Long: not Squeeze AND selected price source > volume-weighted equilibrium
Short: not Squeeze AND selected price source < volume-weighted equilibrium
Long: Equilibrium rising
Short: Equilibrium falling
Long: Adaptive cloud bullish
Short: not Adaptive cloud bullish
Long: Projected equilibrium > Smoothed equilibrium
Short: Projected equilibrium < Smoothed equilibrium
Long: Confidence score >= directional-confidence cutoff AND Bull confidence count >= Bear confidence count
Short: Confidence score >= directional-confidence cutoff AND Bull confidence count < Bear confidence count
Long: low <= Lower bubble band AND the previous main signal side is neutral or short
Short: high >= Upper bubble band AND (the previous main signal side is long OR there is no previous main signal and low > Lower bubble band)
Long: selected price source crosses above Lower cloud band AND selected price source < volume-weighted equilibrium AND High relative volume AND Adaptive cloud bullish
Short: selected price source crosses below Upper cloud band AND selected price source > volume-weighted equilibrium AND High relative volume AND not Adaptive cloud bullish
Long: Squeeze[previous bar] AND not Squeeze AND selected price source > volume-weighted equilibrium AND High relative volume AND Adaptive cloud bullish
Short: Squeeze[previous bar] AND not Squeeze AND selected price source < volume-weighted equilibrium AND High relative volume AND not Adaptive cloud bullish
Long: low <= lowest(low, exhaustion lookback)[previous bar] AND selected price source < Lower cloud band AND (Lower cloud band - selected price source) > volume-weighted range × exhaustion-distance multiplier AND Volume velocity < -volume-deceleration threshold
Short: high >= highest(high, exhaustion lookback)[previous bar] AND selected price source > Upper cloud band AND (selected price source - Upper cloud band) > volume-weighted range × exhaustion-distance multiplier AND Volume velocity < -volume-deceleration threshold
Long: ((bubble-trigger mode selects touch AND low <= Lower bubble band) OR (bubble-trigger mode selects reentry AND low < Lower bubble band AND close > Lower bubble band AND close < volume-weighted equilibrium)) AND (contraction-only filter disabled OR Contraction) AND (Kumo-direction filter disabled OR Adaptive cloud bullish) AND (no prior long bubble signal OR bars since the prior long bubble signal > bubble cooldown)
Short: ((bubble-trigger mode selects touch AND high >= Upper bubble band) OR (bubble-trigger mode selects reentry AND high > Upper bubble band AND close < Upper bubble band AND close > volume-weighted equilibrium)) AND (contraction-only filter disabled OR Contraction) AND (Kumo-direction filter disabled OR not Adaptive cloud bullish) AND (no prior short bubble signal OR bars since the prior short bubble signal > bubble cooldown)