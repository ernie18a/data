Calculation: pivot sequence(lookback) = on each chart bar, reset at each T1 boundary; append alternating highs when highestbars(high, lookback) = 0 and lowestbars(low, lookback) ≠ 0, or lows when lowestbars(low, lookback) = 0 and highestbars(high, lookback) ≠ 0; while direction remains the same, replace the latest high only with a higher high or the latest low only with a lower low; defined after the pivot readiness minimum count
Long: latest pivot high in pivot sequence(short pivot lookback) > preceding pivot high
Short: latest pivot high in pivot sequence(short pivot lookback) ≤ preceding pivot high
Long: latest pivot low in pivot sequence(short pivot lookback) > preceding pivot low
Short: latest pivot low in pivot sequence(short pivot lookback) ≤ preceding pivot low
Long: latest pivot high in pivot sequence(long pivot lookback) > preceding pivot high
Short: latest pivot high in pivot sequence(long pivot lookback) ≤ preceding pivot high
Long: latest pivot low in pivot sequence(long pivot lookback) > preceding pivot low
Short: latest pivot low in pivot sequence(long pivot lookback) ≤ preceding pivot low