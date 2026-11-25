Calculation: Raw upper stop = Highest(high, lookback) - (Highest(high, lookback) - Lowest(low, lookback)) * risk fraction
Calculation: Raw lower stop = Lowest(low, lookback) + (Highest(high, lookback) - Lowest(low, lookback)) * risk fraction
Calculation: Upper stop = min(raw upper stop, prior upper stop) when trend is bearish; otherwise raw upper stop
Calculation: Lower stop = max(raw lower stop, prior lower stop) when trend is bullish; otherwise raw lower stop
Calculation: Trend = bearish when close < prior lower stop; otherwise bullish when close > prior upper stop; otherwise prior trend
Calculation: Bullish stop buffer = rounded lower stop when trend is bullish and prior bearish stop buffer is not positive; otherwise zero
Calculation: Bearish stop buffer = rounded upper stop when trend is bearish and prior bullish stop buffer is not positive; otherwise zero
Long: trend is bullish AND prior bearish stop buffer > 0
Short: trend is bearish AND prior bullish stop buffer > 0
Calculation: In the native version, calculations run on chart bars; in the T1 version, they run on T1 bars using the still-forming bar at its opening, with values held on chart bars until the next T1 bar