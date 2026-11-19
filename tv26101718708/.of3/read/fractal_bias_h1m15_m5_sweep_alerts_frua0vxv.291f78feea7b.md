Calculation: Fractals(T) = an upper/lower fractal when its center high/low is strictly greater/less than every high/low of the fractal-span bars on each side, confirmed after the fractal-span right-side T bars close.
Calculation: Bias(T) = on completed T bars, set Long when close > the latest unbroken confirmed upper fractal and Short when close < the latest unbroken confirmed lower fractal; each newly confirmed fractal replaces the previous level of its side, a broken level is consumed, and bias otherwise persists, including when a new fractal is confirmed.
Calculation: New upper M5 sweep = the first current, still-forming T3 bar with high > the latest confirmed upper fractal on T3; consume that fractal at the first strict breach, including when the bias does not match, and ignore breaches already present when monitoring starts.
Calculation: New lower M5 sweep = the first current, still-forming T3 bar with low < the latest confirmed lower fractal on T3; consume that fractal at the first strict breach, including when the bias does not match, and ignore breaches already present when monitoring starts.
Long: Bias(T1) = Long
Short: Bias(T1) = Short
Long: Bias(T2) = Long
Short: Bias(T2) = Short
Short: Bias(T1) = Short AND Bias(T2) = Short AND New upper M5 sweep
Long: Bias(T1) = Long AND Bias(T2) = Long AND New lower M5 sweep