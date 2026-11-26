Calculation: swing range(L) = highest(high, L) - lowest(low, L)
Calculation: up swing(L) = swing range(L) > 0 AND highestbars(high, L) > lowestbars(low, L)
Calculation: down swing(L) = swing range(L) > 0 AND highestbars(high, L) <= lowestbars(low, L)
Calculation: retracement(L) = if up swing(L), (highest(high, L) - close) / swing range(L); otherwise, (close - lowest(low, L)) / swing range(L)
Long: up swing(View 1 lookback) OR up swing(View 2 lookback) OR up swing(View 3 lookback)
Short: down swing(View 1 lookback) OR down swing(View 2 lookback) OR down swing(View 3 lookback)
Long: up swing(selected view lookback) AND retracement(selected view lookback) >= Zone 1 lower boundary AND retracement(selected view lookback) <= Zone 1 upper boundary
Short: down swing(selected view lookback) AND retracement(selected view lookback) >= Zone 1 lower boundary AND retracement(selected view lookback) <= Zone 1 upper boundary
Long: up swing(selected view lookback) AND retracement(selected view lookback) >= Zone 2 lower boundary AND retracement(selected view lookback) <= Zone 2 upper boundary
Short: down swing(selected view lookback) AND retracement(selected view lookback) >= Zone 2 lower boundary AND retracement(selected view lookback) <= Zone 2 upper boundary
Long: up swing(selected view lookback) AND retracement(selected view lookback) >= Zone 3 lower boundary AND retracement(selected view lookback) <= Zone 3 upper boundary
Short: down swing(selected view lookback) AND retracement(selected view lookback) >= Zone 3 lower boundary AND retracement(selected view lookback) <= Zone 3 upper boundary