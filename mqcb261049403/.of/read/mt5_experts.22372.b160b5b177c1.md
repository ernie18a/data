Calculation: Adaptive level = On each bar, let n be the fractal lookback and l the lag. Let r1 be the high-low range of the latest n bars divided by n, r2 the range of the preceding n bars divided by n, and r3 the range of all 2n bars divided by 2n. Set d=log2((r1+r2)/r3) when r1+r2>0 AND r3>0, otherwise d=0. Set a=clamp(exp(-l*(d-1)),0.01,1), p=(high+low+2*open+2*close)/6, and smooth=a*p+(1-a)*previous smooth, initialized to zero. Set the level to smooth if abs(smooth-smooth l bars earlier)>=l*l*price point, otherwise retain the previous level. Its direction is up when the level rises, down when it falls, and otherwise retains its previous direction, initially neutral.
Calculation: Trailing trend = On each bar, calculate ATR and its highest and lowest values over a separate lookback. Set step to the sensitivity factor times their average, rounded down to a whole price point. Set candidate upper=low+2*step and candidate lower=high-2*step; alternatively use close in place of both low and high. Initialize the previous upper and lower to the first processed close and trend to neutral. Set trend to up if close>previous upper, then set it to down if close<previous lower; otherwise retain its previous value. In an up trend, set lower=max(candidate lower,previous lower) and upper=candidate upper. In a down or neutral trend, set upper=min(candidate upper,previous upper) and lower=candidate lower. For the next bar, replace the upper with positive infinity in an up trend, or the lower with the smallest positive number in a down or neutral trend.
Long: Adaptive level direction = up.
Short: Adaptive level direction = down.
Long: Trailing trend = up.
Short: Trailing trend = down OR neutral.
Long: Trailing trend = up AND previous trailing trend != up.
Short: Trailing trend = down OR neutral AND previous trailing trend = up.
Long: On a higher timeframe, the last completed adaptive level direction = up AND its preceding direction != up.
Short: On a higher timeframe, the last completed adaptive level direction = down AND its preceding direction != down.
Long: On a higher timeframe, the last completed trailing trend = up AND its preceding trend != up.
Short: On a higher timeframe, the last completed trailing trend = down OR neutral AND its preceding trend = up.
Exit: long, on a higher timeframe the last completed adaptive level direction = down OR the last completed trailing trend = down OR neutral.
Exit: short, on a higher timeframe the last completed adaptive level direction = up OR the last completed trailing trend = up.
Exit: long, low <= entry price - stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price - profit distance.