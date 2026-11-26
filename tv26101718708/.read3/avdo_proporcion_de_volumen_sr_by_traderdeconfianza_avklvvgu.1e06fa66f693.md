Calculation: AVDO profile levels = On chart bars, build an age-decayed volume histogram in logarithmic price bins over the profile lookback, from the padded lowest low to padded highest high. Split each bar’s volume between body and wick allocations; distribute wick volume evenly across intersected bins and body volume by overlap. Remove expired bars and rebuild when price leaves the canvas or bin-width drift exceeds its threshold. Derive the volume-weighted mean, interpolated point of control, inner and outer mass bounds, and a center blending the geometric inner-band midpoint toward the weighted mean according to profile asymmetry. EMA-smooth the point of control, inner bounds, and center with a shorter lookback, and outer bounds with a longer lookback.
Calculation: AVDO normalized score(price, anchor, inner bounds, outer bounds) = Clamp a linear score from zero at the anchor to positive or negative inner-bound scores at the inner bounds, then to positive or negative outer-bound scores at the outer bounds; clamp to the outer-bound score. Keep the anchor within the inner bounds and the outer bounds outside the inner bounds.
Calculation: AVDO oscillator = EMA of the weighted sum of the normalized close score relative to the adaptive trail and the normalized close score relative to the point of control, with the point-of-control score weighted by one minus the clamped absolute difference between the scores divided by their full span.
Calculation: AVDO adaptive trail = Blend the AVDO profile center and point of control using a center-bias parameter. Set direction from close relative to this base; reverse direction when close crosses the current anchor against that direction. Offset the base by an ATR distance divided by a clamped acceleration based on normalized close movement and distance from the base, subject to a minimum ATR distance; adjust the anchor toward the base and limit its maximum gap. Use separate parameters for ATR lookback, acceleration sensitivity and cap, flip distance, transition distance, and minimum distance.
Calculation: Critical volume = Let relative volume be volume divided by the highest volume over the critical-volume lookback. Let excess be relative volume minus its EMA. Critical volume is true when excess is positive and at least the highest excess over the critical-volume lookback multiplied by the critical-volume threshold.
Calculation: Volume-proportion trigger = Current volume divided by previous-bar volume is at least the volume-ratio threshold, and the ATR filter is disabled or high minus low is at least ATR times its multiplier, and the body filter is disabled or the nonzero-range candle body as a fraction of its range is at least the minimum body fraction.
Long: EMA(AVDO oscillator, candle-color smoothing lookback) > 0 AND critical volume is false.
Short: EMA(AVDO oscillator, candle-color smoothing lookback) < 0 AND critical volume is false.
Long: AVDO trail direction is bullish AND its prior-bar direction is bullish.
Short: AVDO trail direction is bearish AND its prior-bar direction is bearish.
Long: Volume-proportion trigger AND close >= open.
Short: Volume-proportion trigger AND close < open.
Long: AVDO oscillator crosses above EMA(AVDO oscillator, signal lookback).
Short: AVDO oscillator crosses below EMA(AVDO oscillator, signal lookback).
Long: AVDO oscillator crosses above zero.
Short: AVDO oscillator crosses below zero.
Long: AVDO trail direction changes from bearish to bullish.
Short: AVDO trail direction changes from bullish to bearish.
Long: Close crosses above the AVDO adaptive trail.
Short: Close crosses below the AVDO adaptive trail.
Long: AVDO trail direction is bullish AND close > AVDO adaptive trail AND AVDO oscillator > 0 AND AVDO oscillator > EMA(AVDO oscillator, signal lookback).
Short: AVDO trail direction is bearish AND close < AVDO adaptive trail AND AVDO oscillator < 0 AND AVDO oscillator < EMA(AVDO oscillator, signal lookback).
Long: EMA(AVDO oscillator, reversal smoothing lookback) crosses above its prior-bar value AND AVDO oscillator is below the negative reversal threshold AND low < Lowest(low[1], sweep lookback) AND no reversal mark occurred within the reversal cooldown.
Short: EMA(AVDO oscillator, reversal smoothing lookback) crosses below its prior-bar value AND AVDO oscillator is above the reversal threshold AND high > Highest(high[1], sweep lookback) AND no reversal mark occurred within the reversal cooldown.
Long: Volume-proportion trigger AND critical volume AND close >= open.
Short: Volume-proportion trigger AND critical volume AND close < open.
Long: Volume-proportion trigger AND AVDO bullish alignment: trail direction is bullish, close > AVDO adaptive trail, AVDO oscillator > 0, and AVDO oscillator > EMA(AVDO oscillator, signal lookback).
Short: Volume-proportion trigger AND AVDO bearish alignment: trail direction is bearish, close < AVDO adaptive trail, AVDO oscillator < 0, and AVDO oscillator < EMA(AVDO oscillator, signal lookback).
Long: A later bar intersects a previously formed active bullish volume-proportion box AND AVDO trail direction is bullish.
Short: A later bar intersects a previously formed active bearish volume-proportion box AND AVDO trail direction is bearish.