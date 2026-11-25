Calculation: ADS reference profile = previous ADS profile when the profile session range changes; otherwise the current ADS profile sampled at the ADS reference interval
Calculation: Signal reference profile = the previous signal profile snapshot at the signal reference interval
Calculation: Profile width(profile) = max(VAH(profile) - VAL(profile), minimum tick)
Calculation: Profile overlap(profile, reference) = clamp(intersection width of their value areas / max(union width of their value areas, minimum tick), 0, 1)
Calculation: Profile shift(profile, reference) = (POC(profile) - POC(reference)) / max(Profile width(profile), minimum tick)
Calculation: Accepted direction(profile, confirmation count) = 1 when consecutive closes above VAH(profile) equal the confirmation count, -1 when consecutive closes below VAL(profile) equal the confirmation count, and 0 otherwise
Calculation: Profile bias(profile, reference, accepted direction) = bounded rounded weighted sum of clamped Profile shift, inverse Profile overlap, clamped (close - POC(profile)) / Profile width(profile), and accepted direction, using separate weights for each term
Calculation: ADS bias = Profile bias(ADS profile, ADS reference profile, Accepted direction(ADS profile, acceptance confirmation count))
Calculation: Signal bias = Profile bias(signal profile, signal reference profile, Accepted direction(signal profile, acceptance confirmation count))
Calculation: ADS rotation = bounded rounded normalized count of close crossings of (ADS VAH + ADS VAL) / 2 in the rotation lookback, where the lookback is derived from ADS range length
Calculation: ADS reversal risk = bounded rounded weighted sum of normalized close distance outside the ADS value area, outside-side wick divided by bar range, and the flag for a thin relevant outer profile tail, plus a failed-break penalty; use separate weights, tail fraction, thin-tail threshold, distance reference, penalty, and risk bounds
Calculation: Session CVD = cumulative volume × sign(close - open), reset at each session start; doji bars contribute zero
Long: Accepted direction(ADS profile, acceptance confirmation count) = 1
Short: Accepted direction(ADS profile, acceptance confirmation count) = -1
Long: ADS VAL <= close AND close <= ADS VAH AND ((acceptance confirmation count = 1 AND prior consecutive closes above ADS VAH = 1) OR (acceptance confirmation count > 1 AND prior consecutive closes above ADS VAH > 0 AND prior consecutive closes above ADS VAH < acceptance confirmation count))
Short: ADS VAL <= close AND close <= ADS VAH AND ((acceptance confirmation count = 1 AND prior consecutive closes below ADS VAL = 1) OR (acceptance confirmation count > 1 AND prior consecutive closes below ADS VAL > 0 AND prior consecutive closes below ADS VAL < acceptance confirmation count))
Long: Accepted direction(signal profile, acceptance confirmation count) = 1 on a confirmed chart bar
Short: Accepted direction(signal profile, acceptance confirmation count) = -1 on a confirmed chart bar
Long: signal VAL <= close AND close <= signal VAH AND ((acceptance confirmation count = 1 AND prior consecutive closes above signal VAH = 1) OR (acceptance confirmation count > 1 AND prior consecutive closes above signal VAH > 0 AND prior consecutive closes above signal VAH < acceptance confirmation count)) on a confirmed chart bar
Short: signal VAL <= close AND close <= signal VAH AND ((acceptance confirmation count = 1 AND prior consecutive closes below signal VAL = 1) OR (acceptance confirmation count > 1 AND prior consecutive closes below signal VAL > 0 AND prior consecutive closes below signal VAL < acceptance confirmation count)) on a confirmed chart bar
Long: ADS bias > ADS panel bias threshold OR (Profile overlap(ADS profile, ADS reference profile) <= ADS low-overlap threshold AND abs(Profile shift(ADS profile, ADS reference profile)) >= ADS shift threshold AND ADS rotation <= ADS low-rotation threshold AND ADS bias >= 0 AND Accepted direction(ADS profile, acceptance confirmation count) = 0 AND NOT (ADS failed-break event AND ADS reversal risk >= ADS reversal-risk threshold))
Short: ADS bias < -ADS panel bias threshold OR (Profile overlap(ADS profile, ADS reference profile) <= ADS low-overlap threshold AND abs(Profile shift(ADS profile, ADS reference profile)) >= ADS shift threshold AND ADS rotation <= ADS low-rotation threshold AND ADS bias < 0 AND Accepted direction(ADS profile, acceptance confirmation count) = 0 AND NOT (ADS failed-break event AND ADS reversal risk >= ADS reversal-risk threshold))
Long: Signal bias > 0 on a confirmed chart bar
Short: Signal bias < 0 on a confirmed chart bar
Long: close > signal VAH on a confirmed chart bar
Short: close < signal VAL on a confirmed chart bar
Long: confirmed pivot low(low, pivot lookback, pivot lookback) is below the previous confirmed pivot low AND Session CVD at that pivot is above Session CVD at the previous pivot low AND a session has started AND the pivot-to-pivot bar count exceeds the divergence cooldown
Short: confirmed pivot high(high, pivot lookback, pivot lookback) is above the previous confirmed pivot high AND Session CVD at that pivot is below Session CVD at the previous pivot high AND a session has started AND the pivot-to-pivot bar count exceeds the divergence cooldown