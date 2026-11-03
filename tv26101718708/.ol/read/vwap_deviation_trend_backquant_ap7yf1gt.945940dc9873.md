Calculation: VWAP = volume-weighted mean of the selected price source over the configured anchored or rolling window; if window volume is zero, use its arithmetic mean.
Calculation: Weighted price deviation = square root of max(weighted mean of squared selected prices − VWAP², 0); if window volume is zero, use the unweighted mean of squared prices.
Calculation: Band width = deviation multiplier × weighted price deviation; if the ATR floor is enabled, use the greater of this width and ATR × ATR floor multiplier.
Calculation: Raw upper band = VWAP + band width; raw lower band = VWAP − band width.
Calculation: Lower trailing band = max(current raw lower band, previous lower trailing band) when the previous trigger is above the previous lower trailing band; otherwise, current raw lower band.
Calculation: Upper trailing band = min(current raw upper band, previous upper trailing band) when the previous trigger is below the previous upper trailing band; otherwise, current raw upper band.
Calculation: Flip trigger = configured choice of close or selected VWAP price source.
Long: Flip trigger > upper trailing band AND current trend is not bullish AND (slope confirmation is disabled OR current VWAP > VWAP at the configured lookback).
Short: Flip trigger < lower trailing band AND current trend is not bearish AND (slope confirmation is disabled OR current VWAP < VWAP at the configured lookback).