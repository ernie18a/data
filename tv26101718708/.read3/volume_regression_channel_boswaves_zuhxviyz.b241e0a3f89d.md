Calculation: Regression channel = each OLS polynomial regression(HL2, regression lookback, degree parameter) fitted value ± standard deviation(HL2, regression lookback) × channel-width parameter
Calculation: Flow = for each segment of ceil((regression lookback − 1) / segment-count parameter) bars in the regression window, volume-weighted mean of 2 × clamp((close − low) / max(high − low, minimum price increment), 0, 1) − 1, weighted by min(volume / SMA(volume, volume lookback), volume cap parameter); adjacent segments share their boundary bar
Long: close > linear regression(HL2, regression lookback, offset 0)
Short: close ≤ linear regression(HL2, regression lookback, offset 0)
Long: low ≤ lower regression-channel band AND (bar is oldest in regression window OR low[1] > lower regression-channel band[1])
Short: high ≥ upper regression-channel band AND (bar is oldest in regression window OR high[1] < upper regression-channel band[1])
Long: relative volume ≥ flare-volume parameter AND low ≥?
Long: relative volume ≥ flare-volume parameter AND low ≤ center − channel half-width × (1 − flare-zone parameter) AND (high < center + channel half-width × (1 − flare-zone parameter) OR distance(close, lower band) < distance(close, upper band))
Short: relative volume ≥ flare-volume parameter AND high ≥ center + channel half-width × (1 − flare-zone parameter) AND (low > center − channel half-width × (1 − flare-zone parameter) OR distance(close, upper band) ≤ distance(close, lower band))
Long: Flow ≥ flow-direction threshold parameter
Short: Flow ≤ −flow-direction threshold parameter