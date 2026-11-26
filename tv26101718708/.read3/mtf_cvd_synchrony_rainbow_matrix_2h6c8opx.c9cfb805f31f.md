Calculation: Smoothed signed volume delta(T) = EMA((high == low ? 0 : ((close - low) - (high - close)) / (high - low)) × volume, smoothing length(T)); calculate on T bars, with separate smoothing lengths for T1–T5, ordered fastest to slowest
Calculation: CVD score(T) = if highest(abs(Smoothed signed volume delta(T)), normalization window(T)) > 0 then clamp(50 + 50 × Smoothed signed volume delta(T) / highest(abs(Smoothed signed volume delta(T)), normalization window(T)), 0, 100) else 50; calculate on T bars with a separate normalization window for each T1–T5; chart bars receive the latest available T value with lookahead off, including the still-forming T bar in real time
Calculation: Master CVD score = weighted mean of the available CVD scores on T1–T5, using a separate weight for each timeframe and renormalizing over available scores; calculate on chart bars
Calculation: Master channel high = EMA(highest(Master CVD score, channel lookback), channel smoothing)
Calculation: Master channel low = EMA(lowest(Master CVD score, channel lookback), channel smoothing)
Calculation: Dynamic Z-exhaustion high/low = clamp(channel midpoint ± max(channel high − channel midpoint, channel midpoint − channel low, minimum range) × Z-exhaustion expansion factor, 0, 100), where channel midpoint = (Master channel high + Master channel low) / 2
Calculation: Dynamic Black Swan high/low = clamp(channel midpoint ± max(channel high − channel midpoint, channel midpoint − channel low, minimum range) × Black Swan expansion factor, 0, 100), where channel midpoint = (Master channel high + Master channel low) / 2
Calculation: Black Swan upper/lower threshold = dynamic Black Swan high/low when dynamic mode is enabled; otherwise the corresponding static threshold
Long: Master CVD score > 50
Short: Master CVD score < 50
Long: Any CVD score on T1–T5 or Master CVD score ≥ buy-pressure state threshold
Short: Any CVD score on T1–T5 or Master CVD score ≤ sell-pressure state threshold
Long: Any CVD score on T1–T5 or Master CVD score on the current chart bar > its previous chart-bar value + trend deadzone
Short: Any CVD score on T1–T5 or Master CVD score on the current chart bar < its previous chart-bar value − trend deadzone
Long: On any T1–T5 bars, at a newly confirmed pivot low of Smoothed signed volume delta(T), its value is greater than at the preceding such pivot low AND instrument low at that pivot is less than instrument low at the preceding such pivot; chart bars receive the latest available T result with lookahead off, including the still-forming T bar in real time
Short: On any T1–T5 bars, at a newly confirmed pivot high of Smoothed signed volume delta(T), its value is less than at the preceding such pivot high AND instrument high at that pivot is greater than instrument high at the preceding such pivot; chart bars receive the latest available T result with lookahead off, including the still-forming T bar in real time
Long: On a chart bar with a newly confirmed pivot low of Master CVD score, its value is greater than at the preceding such pivot low AND instrument low at that pivot is less than instrument low at the preceding such pivot
Short: On a chart bar with a newly confirmed pivot high of Master CVD score, its value is less than at the preceding such pivot high AND instrument high at that pivot is greater than instrument high at the preceding such pivot
Long: On a confirmed chart bar, CVD score(T1) ≤ strong lower-extreme threshold AND CVD score(T5) ≥ strong upper-extreme threshold
Short: On a confirmed chart bar, CVD score(T1) ≥ strong upper-extreme threshold AND CVD score(T5) ≤ strong lower-extreme threshold
Long: On a confirmed chart bar, CVD score(T1) ≤ moderate lower threshold AND CVD score(T5) ≥ moderate upper threshold AND neither strong-extreme condition holds
Short: On a confirmed chart bar, CVD score(T1) ≥ moderate upper threshold AND CVD score(T5) ≤ moderate lower threshold AND neither strong-extreme condition holds
Long: On a confirmed chart bar, Master CVD score crosses above Black Swan upper threshold
Short: On a confirmed chart bar, Master CVD score crosses below Black Swan lower threshold
Long: On a confirmed chart bar, Master CVD score crosses above dynamic Z-exhaustion high
Short: On a confirmed chart bar, Master CVD score crosses below dynamic Z-exhaustion low