Calculation: VWAP center and deviation = For the selected rolling window or current daily session, compute the volume-weighted mean and standard deviation of (high + low) / 2. In session mode, use the current bar's midpoint and zero deviation when cumulative volume is zero.
Calculation: Adaptive bands = EMA of VWAP center ± deviation × base multiplier × (1 + max(0, volume / SMA(volume) − 1) × volume sensitivity) × (1 + ADX / 100 × ADX influence). Use a volume ratio of 1 when average volume is not positive and an ADX of 0 when unavailable.
Calculation: Smoothed wick ratio = For each lower-timeframe bar within the current chart bar, including the still-forming lower-timeframe bar, allocate its volume between body and wick according to the fraction of its high–low range overlapping the chart bar's open–close body; use a minimum price increment as the denominator floor. Divide summed wick volume by summed volume, or use zero when summed volume is zero, then take its SMA. If no lower-timeframe bars are available, use the chart bar's body-to-range fraction instead.
Calculation: Wick intensity = clamp((smoothed wick ratio − wick intensity baseline) / (1 − wick intensity baseline), 0, 1) × ADX gate. The gate is 1 when ADX filtering is disabled or ADX meets its gate threshold; otherwise it is a reduced positive multiplier.
Calculation: Upper intensity = wick intensity when high > upper adaptive band + zone offset × deviation; otherwise 0. Lower intensity = wick intensity when low < lower adaptive band − zone offset × deviation; otherwise 0.
Calculation: Session-average upper and lower intensity = arithmetic mean of the respective intensity from the start of the current daily session through the current bar, including zero values.
Long: Lower intensity > 0
Short: Upper intensity > 0
Long: Lower intensity > lower intensity display threshold
Short: Upper intensity > upper intensity display threshold
Long: Session-average lower intensity > session-average threshold
Short: Session-average upper intensity > session-average threshold
Long: Lower intensity > buy alert threshold AND smoothed wick ratio >= wick ratio threshold
Short: Upper intensity > sell alert threshold AND smoothed wick ratio >= wick ratio threshold
Long: Positive directional indicator > negative directional indicator
Short: Positive directional indicator <= negative directional indicator