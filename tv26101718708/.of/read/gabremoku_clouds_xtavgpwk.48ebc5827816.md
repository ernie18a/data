Calculation: Typical price = (high + low + close) / 3.
Calculation: Volume-weighted equilibrium for a lookback = sum(volume × typical price) / sum(volume) over that lookback; if the volume sum is zero, use current typical price.
Calculation: Volume-weighted average spread = sum(volume × (high − low)) / sum(volume) over the equilibrium lookback; if the volume sum is zero, use current high − low.
Calculation: Bubble bands = equilibrium ± a bubble-band multiplier × volume-weighted average spread.
Calculation: Kumo span A = average of volume-weighted equilibria using shorter and longer lookbacks. Kumo span B = average of the highest and lowest typical prices over a wide lookback longer than the span A lookbacks. Use current, unshifted values.
Calculation: Squeeze = (volume-weighted average spread − its lowest value over a lookback) / (its highest value over that lookback − its lowest value over that lookback); use zero if the range is zero.
Calculation: Projected equilibrium = EMA of equilibrium + EMA of (change in that equilibrium EMA over a slope lookback / slope lookback) × projection horizon × damping factor. Use the current, unshifted value.
Long: Low <= lower bubble band AND the previous alternating touch signal is short or no alternating touch signal has occurred.
Short: High >= upper bubble band AND (the previous alternating touch signal is long OR no alternating touch signal has occurred AND low > lower bubble band).
Long: (Low <= lower bubble band in touch mode OR low < lower bubble band AND close > lower bubble band AND close < equilibrium in reentry mode) AND (contraction filter disabled OR absolute change in equilibrium over equilibrium lookback minus one bars < volume-weighted average spread × flat-slope threshold) AND (Kumo filter disabled OR Kumo span A >= Kumo span B) AND (no previous long bubble signal OR bars since previous long bubble signal > cooldown).
Short: (High >= upper bubble band in touch mode OR high > upper bubble band AND close < upper bubble band AND close > equilibrium in reentry mode) AND (contraction filter disabled OR absolute change in equilibrium over equilibrium lookback minus one bars < volume-weighted average spread × flat-slope threshold) AND (Kumo filter disabled OR Kumo span A < Kumo span B) AND (no previous short bubble signal OR bars since previous short bubble signal > cooldown).
Long: Squeeze > squeeze threshold AND close > equilibrium.
Short: Squeeze > squeeze threshold AND close < equilibrium.
Long: Kumo span A >= Kumo span B.
Short: Kumo span A < Kumo span B.
Long: Projected equilibrium > its equilibrium EMA base.
Short: Projected equilibrium < its equilibrium EMA base.