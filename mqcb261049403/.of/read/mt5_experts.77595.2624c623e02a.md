Calculation: Trading session = start hour <= hour of datetime < end hour.
Calculation: Flexible session = selected start time <= time of datetime <= selected end time when start < end; time of datetime >= start OR time of datetime <= end when start > end; always true when start = end. The selected session may be a custom session, a selected configured zone, or the union of all configured zones; optionally exclude weekends.
Calculation: Volatility distance = population standard deviation of true range over the lookback multiplied by (2 - efficiency ratio), where efficiency ratio is the absolute change in close from the oldest to the newest close in the lookback divided by the sum of absolute consecutive close changes in that lookback; use zero for the ratio when the path length is zero.
Calculation: Directional components = over a base lookback, sum positive close-to-previous-close changes as upward movement, sum the absolute negative changes as downward movement, and sum all absolute changes plus a small positive constant as path length. Multiply each of upward movement, downward movement, and the absolute difference between them divided by path length by the population standard deviation of close over the base lookback. For each resulting series, calculate the rolling population z-score over a separate lookback, using zero when variance is negligible, then apply 100 / (1 + exp(-sensitivity * z-score)). The three results are upward, downward, and trend components.
Long: Current chart-bar close > current chart-bar Parabolic SAR AND trading session = true AND position side != long.
Short: Current chart-bar close < current chart-bar Parabolic SAR AND trading session = true AND position side != short.
Exit: long, current chart-bar close < current chart-bar Parabolic SAR AND trading session = true.
Exit: short, current chart-bar close > current chart-bar Parabolic SAR AND trading session = true.
Long: Current chart-bar close >= simple moving average of close AND flexible session = true AND position side != long.
Short: Current chart-bar close < simple moving average of close AND flexible session = true AND position side != short.
Exit: long, current chart-bar close < simple moving average of close.
Exit: short, current chart-bar close >= simple moving average of close.
Long: Current chart-bar close - simple moving average of close > positive noise threshold AND flexible session = true AND (dynamic volatility mode = disabled OR volatility distance >= minimum volatility threshold) AND (style filter = disabled OR (trend component >= style threshold AND upward component > downward component)) AND position side != long.
Short: Current chart-bar close - simple moving average of close < negative noise threshold AND flexible session = true AND (dynamic volatility mode = disabled OR volatility distance >= minimum volatility threshold) AND (style filter = disabled OR (trend component >= style threshold AND downward component > upward component)) AND position side != short.
Exit: long, current chart-bar close - simple moving average of close < negative noise threshold.
Exit: short, current chart-bar close - simple moving average of close > positive noise threshold.
Long: Shorter-period exponential moving average of close > middle-period exponential moving average of close AND middle-period exponential moving average of close > longer-period exponential moving average of close AND position side != long.
Short: Shorter-period exponential moving average of close < middle-period exponential moving average of close AND middle-period exponential moving average of close < longer-period exponential moving average of close AND position side != short.
Exit: long, shorter-period exponential moving average of close < middle-period exponential moving average of close AND middle-period exponential moving average of close < longer-period exponential moving average of close.
Exit: short, shorter-period exponential moving average of close > middle-period exponential moving average of close AND middle-period exponential moving average of close > longer-period exponential moving average of close.
Exit: long, stop loss enabled AND low <= entry price - stop distance.
Exit: long, take profit enabled AND high >= entry price + profit distance.
Exit: short, stop loss enabled AND high >= entry price + stop distance.
Exit: short, take profit enabled AND low <= entry price - profit distance.