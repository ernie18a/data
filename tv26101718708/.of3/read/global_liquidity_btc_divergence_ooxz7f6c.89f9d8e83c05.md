Calculation: Net liquidity = central bank assets close(T1, current bar, still forming), minus treasury account close(T1, current bar, still forming), minus reverse repo close(T1, current bar, still forming), sampled on chart bars from T1
Calculation: Liquidity normalization = (net liquidity - lowest(net liquidity, lookback)) / (highest(net liquidity, lookback) - lowest(net liquidity, lookback)), with the lookback computed over chart bars
Calculation: Price normalization = (close(T1, current bar, still forming) - lowest(close(T1, current bar, still forming), lookback)) / (highest(close(T1, current bar, still forming), lookback) - lowest(close(T1, current bar, still forming), lookback)), with the lookback computed over chart bars
Calculation: Divergence = liquidity normalization - price normalization
Long: Divergence > 0
Short: Divergence <= 0
Calculation: net liquidity = Federal Reserve total assets on T1 − Treasury General Account balance on T1 − overnight reverse repurchase agreements on T1
Calculation: normalized liquidity divergence = (net liquidity − lowest(net liquidity, P1)) / (highest(net liquidity, P1) − lowest(net liquidity, P1)) − (Bitcoin close on T1 − lowest(Bitcoin close on T1, P1)) / (highest(Bitcoin close on T1, P1) − lowest(Bitcoin close on T1, P1))
Long: normalized liquidity divergence > 0
Short: normalized liquidity divergence ≤ 0