Calculation: Real Relative Strength(B) = EMA(((instrument close − instrument close momentum period bars ago) − (B close − B close momentum period bars ago)) / (average(ATR(momentum period) of instrument, ATR(momentum period) of B) × ATR multiplier), smoothing period)
Long: Real Relative Strength(primary benchmark) ≥ 0
Short: Real Relative Strength(primary benchmark) < 0
Long: Real Relative Strength(primary benchmark) crosses above 0 AND (second-benchmark agreement is disabled OR Real Relative Strength(second benchmark) > 0) AND (cooldown is disabled OR bars since prior confirmed zero-cross signal ≥ cooldown period)
Short: Real Relative Strength(primary benchmark) crosses below 0 AND (second-benchmark agreement is disabled OR Real Relative Strength(second benchmark) < 0) AND (cooldown is disabled OR bars since prior confirmed zero-cross signal ≥ cooldown period)
Long: Real Relative Strength(primary benchmark) ≥ strong/weak level
Short: Real Relative Strength(primary benchmark) ≤ −strong/weak level
Long: Real Relative Strength(primary benchmark) > strong/weak level × extreme-background multiplier
Short: Real Relative Strength(primary benchmark) < −strong/weak level × extreme-background multiplier
Long: divergence detection is enabled AND a confirmed Real Relative Strength pivot low is higher than the prior confirmed pivot low AND instrument low at that pivot is lower than at the prior pivot low (pivot length)
Short: divergence detection is enabled AND a confirmed Real Relative Strength pivot high is lower than the prior confirmed pivot high AND instrument high at that pivot is higher than at the prior pivot high (pivot length)