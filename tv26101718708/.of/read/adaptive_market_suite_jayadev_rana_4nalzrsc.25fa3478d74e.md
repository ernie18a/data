Calculation: Adaptive average = Initialize to close; thereafter add the smoothing coefficient times (close minus the previous adaptive average). The smoothing coefficient is the square of (efficiency ratio times (fast smoothing constant minus slow smoothing constant) plus slow smoothing constant). Each smoothing constant is 2 divided by its length plus 1. The efficiency ratio is the absolute change in close over its lookback divided by the sum of absolute one-bar close changes over that lookback, or zero when that sum is zero. The fast smoothing length is shorter than the slow smoothing length.
Calculation: Order-flow oscillator = EMA of close-position pressure times relative volume, using the same length as the volume SMA. Close-position pressure is 2 times (close minus low) divided by (high minus low), minus 1; use -1 when high equals low. Relative volume is volume divided by its SMA when both are positive, otherwise 1.
Calculation: Latest confirmed swing high or low = The most recent pivot high or low confirmed by equal numbers of bars on each side; update it on the confirmation bar before evaluating a break.
Long: Adaptive average > previous adaptive average
Short: Adaptive average <= previous adaptive average
Long: Close > latest confirmed swing high AND previous close <= current latest confirmed swing high
Short: Close < latest confirmed swing low AND previous close >= current latest confirmed swing low
Long: Low > high two bars ago
Short: High < low two bars ago
Long: Order-flow oscillator >= 0
Short: Order-flow oscillator < 0
Long: Order-flow oscillator > 0 AND previous order-flow oscillator <= 0
Short: Order-flow oscillator < 0 AND previous order-flow oscillator >= 0