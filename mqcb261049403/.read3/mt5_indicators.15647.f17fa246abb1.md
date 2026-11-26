Calculation: channel range = highest(high, channel lookback) - lowest(low, channel lookback)
Calculation: raw upper stop = highest(high, channel lookback) - range fraction × channel range
Calculation: raw lower stop = lowest(low, channel lookback) + range fraction × channel range
Calculation: upper trailing stop = min(raw upper stop, prior upper trailing stop) in a downtrend; otherwise raw upper stop
Calculation: lower trailing stop = max(raw lower stop, prior lower trailing stop) in an uptrend; otherwise raw lower stop
Calculation: trend = -1 if close < prior lower trailing stop; otherwise 1 if close > prior upper trailing stop; otherwise prior trend
Calculation: bearish stop buffer = upper trailing stop if trend = -1 and (signal setting disabled or prior bullish stop buffer = 0); otherwise 0
Calculation: bullish stop buffer = lower trailing stop if trend = 1 and (signal setting disabled or prior bearish stop buffer = 0); otherwise 0
Long: signal setting enabled AND trend = 1 AND prior bearish stop buffer > 0
Short: signal setting enabled AND trend = -1 AND prior bullish stop buffer > 0
Long: signal setting enabled AND T1 trend = 1 AND prior T1 bearish stop buffer > 0, calculated on T1 bars using the T1 bar still forming, sampled on the first chart bar at or after each T1 open and held on later chart bars until the next T1 open
Short: signal setting enabled AND T1 trend = -1 AND prior T1 bullish stop buffer > 0, calculated on T1 bars using the T1 bar still forming, sampled on the first chart bar at or after each T1 open and held on later chart bars until the next T1 open