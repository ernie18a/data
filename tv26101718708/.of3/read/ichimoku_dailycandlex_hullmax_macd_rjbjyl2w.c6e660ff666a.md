Calculation: Donchian midpoint = (lowest(low, lookback) + highest(high, lookback)) / 2
Calculation: Cloud line A = average(Donchian midpoint(shortest conversion lookback), Donchian midpoint(intermediate base lookback))
Calculation: Cloud line B = Donchian midpoint(longest lagging-span lookback)
Calculation: HMA MACD = HMA(open, fast lookback) - HMA(open, slow lookback)
Calculation: HMA MACD signal = HMA(HMA MACD, signal lookback shorter than fast lookback)
Long: HMA(open, lookback) > HMA(open[1], same lookback) AND T1 open (current, potentially still-forming T1 bar, sampled on chart bars with lookahead off) > T1 open[1] (previous completed T1 bar) AND open > HMA(open[1], same lookback) AND Cloud line A > Cloud line B AND HMA MACD > HMA MACD signal
Short: HMA(open, lookback) < HMA(open[1], same lookback) AND T1 open (current, potentially still-forming T1 bar, sampled on chart bars with lookahead off) < T1 open[1] (previous completed T1 bar) AND open < HMA(open[1], same lookback) AND Cloud line A < Cloud line B AND HMA MACD < HMA MACD signal