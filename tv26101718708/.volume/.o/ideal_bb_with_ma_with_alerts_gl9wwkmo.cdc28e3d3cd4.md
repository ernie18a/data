Calculation: HMA(x, length) = WMA(2 × WMA(x, length/2) − WMA(x, length), round(sqrt(length)))
Calculation: HMA3(close, length) = WMA(3 × WMA(close, p/3) − WMA(close, p/2) − WMA(close, p), p), where p = length/2
Calculation: Kahlman(x, gain) = recursively, with prior filter value initialized to x and prior velocity to 0: delta = x − prior filter value; smooth = prior filter value + delta × sqrt(2 × gain/10000); velocity = prior velocity + delta × gain/10000; output = smooth + velocity
Calculation: a = Kahlman(HMA(hl2, lookback), gain) when Kahlman is enabled; otherwise HMA(hl2, lookback)
Calculation: b = Kahlman(HMA3(close, lookback), gain) when Kahlman is enabled; otherwise HMA3(close, lookback)
Long: b > a AND prior-bar b < prior-bar a
Short: a > b AND prior-bar a < prior-bar b