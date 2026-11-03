Calculation: Prior bar = last completed chart-timeframe bar
Calculation: Price-to-moving-average deviations = prior open or close's percentage distance from simple moving averages; use shorter and longer lookbacks where paired
Calculation: Rounded deviation = price-to-moving-average deviation multiplied by its signal-family scale, then rounded to the nearest integer
Calculation: MACD pair = rounded MACD main-line value and rounded change from the preceding completed bar
Calculation: CCI pair = rounded CCI value and rounded change from the preceding completed bar
Calculation: Candle-shape triple = rounded prior-bar range, distance from high to open, and distance from high to close, each normalized by the prior-bar range
Calculation: Bulls/Bears pair = rounded sum of Bulls Power and Bears Power, and rounded change in that sum from the preceding completed bar
Calculation: Time/range pair = rounded time-of-week bucket and rounded high-low range over the corresponding lookback
Calculation: Each of 10 long signals = whether its assigned rounded feature pair or triple matches any member of its optimized long-pattern set
Calculation: Each of 10 short signals = whether its assigned rounded feature pair or triple matches any member of its optimized short-pattern set
Calculation: Long-signal count = number of true long signals
Calculation: Short-signal count = number of true short signals
Long: flat AND long-signal count >= minimum confirmations AND long-signal count > short-signal count
Short: flat AND short-signal count >= minimum confirmations AND long-signal count < short-signal count
Exit: long, price <= entry price - stop-loss distance OR price >= entry price + take-profit distance OR elapsed bars since entry >= configured holding bars
Exit: short, price >= entry price + stop-loss distance OR price <= entry price - take-profit distance OR elapsed bars since entry >= configured holding bars