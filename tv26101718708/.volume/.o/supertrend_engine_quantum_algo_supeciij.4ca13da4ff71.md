Calculation: Efficiency Ratio = absolute change in close over the lookback divided by the sum of absolute close-to-close changes over that lookback; use 0 if the denominator is 0
Calculation: Adaptive SuperTrend bands = midpoint (high + low)/2 ± Average True Range × [trend-bound factor + (1 − Efficiency Ratio) × (chop-bound factor − trend-bound factor)]; ratchet the lower band upward to the greater of its raw value and prior lower band when prior close is above the prior lower band, otherwise use its raw value; ratchet the upper band downward to the lesser of its raw value and prior upper band when prior close is below the prior upper band, otherwise use its raw value
Long: current trend state is short AND close > prior upper band + shield margin × Average True Range
Short: current trend state is long AND close < prior lower band − shield margin × Average True Range
Exit: long, close < active lower band
Exit: short, close > active upper band