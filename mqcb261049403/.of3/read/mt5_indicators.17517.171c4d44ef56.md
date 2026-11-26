Calculation: Target = ((MA(IBS, IBS lookback, IBS smoothing method) - 0.5) * 100 * IBS weight + CCI(CCI lookback, CCI applied price) * CCI weight + (RSI(RSI lookback, RSI applied price) - 50) * RSI weight) / 3
Calculation: Composite[t] = if abs(Target[t] - Composite[t-1]) > deadband threshold then Target[t] - sign(Target[t] - Composite[t-1]) * deadband threshold else Composite[t-1]
Calculation: Channel midpoint = (MA(Highest(Composite, range lookback), channel smoothing lookback, channel smoothing method) + MA(Lowest(Composite, range lookback), channel smoothing lookback, channel smoothing method)) / 2
Long: Composite > Channel midpoint
Short: Composite < Channel midpoint
Long: Composite(T1, still-forming bar) > Channel midpoint(T1, still-forming bar), using values copied to chart bars at the first chart bar of each T1 bar and held until the next T1 bar
Short: Composite(T1, still-forming bar) < Channel midpoint(T1, still-forming bar), using values copied to chart bars at the first chart bar of each T1 bar and held until the next T1 bar