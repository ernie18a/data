Calculation: CVD delta(T) = CVD close(T) - CVD open(T), using volume delta aggregated from lower timeframe L within anchor timeframe A
Long: CVD delta(T1) >= 0
Short: CVD delta(T1) < 0
Long: Flow lane intensity >= its balance threshold AND Flow lane signed value > its bullish threshold
Short: Flow lane intensity >= its balance threshold AND Flow lane signed value < its bearish threshold
Long: Response signed value > its bullish color threshold
Short: Response signed value < its bearish color threshold
Long: Structure state is bullish
Short: Structure state is bearish
Long: Adaptive divergence score >= its threshold AND the selected price signal is positive
Short: Adaptive divergence score >= its threshold AND the selected price signal is negative
Calculation: Adaptive divergence score = maximum across the short-, mid-, and long-lookback scales of the divergence score for that scale multiplied by its volatility-adjusted scale weight; a scale's divergence score is zero unless price and CVD signals have opposite signs and both exceed the minimum signal magnitude, otherwise it is the square root of the absolute product of those signals multiplied by the scale weight
Calculation: Composite signal = clamp to [-1,1] of (flow lane signed value × flow weight + response signed value × response weight + structure lane signed value × structure weight) × (0.5 + 0.5 × directional coherence) × (0.5 + 0.5 × regime quality), where directional coherence is the absolute composite directional value divided by the weighted sum of the absolute lane values, clamped to [0,1]
Calculation: Composite threshold = base threshold + noise score × noise weight + dislocation score × dislocation weight
Long: Composite signal >= composite threshold
Short: Composite signal <= -composite threshold
Calculation: Absorption on T = negative CVD delta with flow intensity and bullish resistance above their adaptive thresholds, body relative to ATR above its adaptive lower tolerance, and close location at or above its adaptive lower bound; bearish absorption is the sign-reversed condition using the adaptive upper tolerance and close-location bound
Calculation: AAA on T = absorption followed within an adaptive window by acceptance, then aggression; bullish acceptance requires compression above its adaptive threshold, low holding above the prior bullish absorption low within ATR-scaled tolerance, and close at or above that low; bearish acceptance is the sign-reversed condition at the prior bearish absorption high; bullish aggression requires a close above the prior bullish absorption high, positive flow above its threshold, aggression score above its adaptive threshold, and body efficiency above its adaptive threshold; bearish aggression is the sign-reversed condition
Calculation: Exhaustion on T = bullish decay score above its adaptive threshold with close location above its lower bound, or bearish decay score below the negative adaptive threshold with close location below its upper bound
Long: On a confirmed chart bar, the last completed T bar is classified bullish Absorption, AAA, or Exhaustion AND the current T bar has a positive or negative two-bar CVD gap, or a same-anchor three-bar CVD gap, AND the source interval passes the enabled session filter
Short: On a confirmed chart bar, the last completed T bar is classified bearish Absorption, AAA, or Exhaustion AND the current T bar has a positive or negative two-bar CVD gap, or a same-anchor three-bar CVD gap, AND the source interval passes the enabled session filter