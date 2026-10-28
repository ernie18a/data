Calculation: Per-bar volume delta = volume if close > open, −volume if close < open, and 0 if close = open
Calculation: Cumulative volume delta = running sum of per-bar volume delta
Calculation: Detrended cumulative volume delta = cumulative volume delta − its exponential moving average
Calculation: Confirmed swing high/low = high/low at a bar that is higher/lower than the corresponding values for the same number of bars before and after it; use only after those following bars have closed
Calculation: Divergence strength = clamp((absolute difference between the two detrended cumulative volume delta readings ÷ recent highest-to-lowest range of detrended cumulative volume delta) × 100, 0, 100)
Long: current confirmed swing low < previous confirmed swing low AND detrended cumulative volume delta at current swing > its value at the previous swing AND divergence strength >= minimum strength
Short: current confirmed swing high > previous confirmed swing high AND detrended cumulative volume delta at current swing < its value at the previous swing AND divergence strength >= minimum strength