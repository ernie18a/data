Calculation: openMA, closeMA = the same moving average (same type and length) applied to the open series and to the close series respectively, each computed on a higher timeframe than the chart (bar still forming, updated on every chart bar), with the source series optionally lagged by a few bars
Calculation: slopeAngle = -round(degrees(atan(y))), where y = (EMA(close)[1] - EMA(close)) / hlc3 * scale. The EMA is computed on the chart timeframe. scale = constant / (highest high - lowest low over a lookback) * lowest low over the same lookback. slopeAngle is positive when the EMA is rising and negative when it is falling.
Calculation: choppy = slopeAngle < a small positive threshold
Long: closeMA crosses above openMA AND NOT choppy
Short: closeMA crosses below openMA AND choppy
Exit: long, closeMA crosses below openMA OR close <= entry price - stop distance OR close >= entry price + target distance (stop and target are optional)
Exit: short, closeMA crosses above openMA OR close >= entry price + stop distance OR close <= entry price - target distance (stop and target are optional)