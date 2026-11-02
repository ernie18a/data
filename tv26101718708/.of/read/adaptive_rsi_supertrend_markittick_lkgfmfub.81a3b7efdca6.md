Calculation: Adaptive RSI = Let U and L be the highest and lowest closes over its lookback, and R = U − L. Set D to R if U > previous U, otherwise to −R if L < previous L, otherwise to close − previous close. Return midpoint + midpoint × RMA(D) / RMA(abs(D)), using the same lookback; return midpoint if the denominator is zero.
Calculation: Oscillator supertrend = RMA(abs(Adaptive RSI − previous Adaptive RSI)) over its volatility lookback defines volatility. Upper and lower bands are Adaptive RSI plus and minus a factor times volatility. Initialize the supertrend to the upper band and direction to up. Thereafter, set direction up if Adaptive RSI > previous supertrend, down if Adaptive RSI < previous supertrend, and otherwise retain the previous direction. In the up direction, supertrend = max(lower band, previous supertrend); in the down direction, supertrend = min(upper band, previous supertrend).
Calculation: Filtered oscillator = Apply one selected filter to Adaptive RSI: RMA; or a scalar Kalman filter initialized with estimate = Adaptive RSI and covariance = 1, then each bar add process noise to covariance, set gain = covariance / (covariance + measurement noise), update estimate += gain × (Adaptive RSI − estimate), and update covariance *= 1 − gain; or an adaptive filter initialized to Adaptive RSI, with efficiency = min(abs(Adaptive RSI − Adaptive RSI one filter lookback ago) / (highest Adaptive RSI − lowest Adaptive RSI over that lookback), 1), or zero if the range is zero, and output += (minimum alpha + efficiency × (maximum alpha − minimum alpha)) × (Adaptive RSI − output).
Calculation: Merged line = Average the filtered oscillator and oscillator supertrend, or use the filtered oscillator if the supertrend is unavailable. Optionally smooth the result with SMA, RMA, WMA applied twice, volume-weighted MA applied three times, or HMA, each using its smoothing lookback.
Calculation: Oscillator angle = atan((Adaptive RSI − Adaptive RSI one oscillator lookback ago) / oscillator lookback), in degrees.
Calculation: Regime score = clamp((Adaptive RSI − lower oscillator threshold) / (upper oscillator threshold − lower oscillator threshold), 0, 1) × one quarter of the score scale + clamp(oscillator angle / a right angle + one half, 0, 1) × one quarter of the score scale + one quarter of the score scale if oscillator supertrend direction is up + one quarter of the score scale if close > RMA(close).
Long: Adaptive RSI on the previous chart bar > merged line on the previous chart bar AND Adaptive RSI two chart bars ago <= merged line two chart bars ago AND, if enabled, current volume >= its SMA × volume multiplier AND, if enabled, Adaptive RSI on the last completed higher-timeframe bar >= oscillator midpoint.
Short: Adaptive RSI on the previous chart bar < merged line on the previous chart bar AND Adaptive RSI two chart bars ago >= merged line two chart bars ago AND, if enabled, current volume >= its SMA × volume multiplier AND, if enabled, Adaptive RSI on the last completed higher-timeframe bar < oscillator midpoint.
Long: Oscillator supertrend direction is up.
Short: Oscillator supertrend direction is down.
Long: Oscillator angle > SMA of oscillator angle over the oscillator lookback AND Adaptive RSI >= merged line.
Short: Oscillator angle < SMA of oscillator angle over the oscillator lookback AND Adaptive RSI <= merged line.
Long: Adaptive RSI >= merged line.
Short: Adaptive RSI < merged line.
Long: Oscillator angle > 0.
Short: Oscillator angle < 0.
Long: Adaptive RSI on the last completed higher-timeframe bar >= oscillator midpoint.
Short: Adaptive RSI on the last completed higher-timeframe bar < oscillator midpoint.
Long: Regime score >= bullish regime threshold.
Short: Regime score < bearish regime threshold.