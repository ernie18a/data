Calculation: Intrabar delta = sum of lower-timeframe volume from bars with close > open minus sum of lower-timeframe volume from bars with close < open within the current chart bar; include completed lower-timeframe bars and the lower-timeframe bar still forming. Unchanged lower-timeframe bars contribute zero.
Calculation: Intrabar delta percentage = intrabar delta divided by total lower-timeframe volume within the current chart bar, multiplied by 100; use zero when total volume is zero.
Calculation: Lookback delta = sum over the lookback window including the current chart bar of volume multiplied by a fixed positive weight for bars with close > open, minus volume multiplied by the same weight for bars with close < open; unchanged bars contribute zero.
Calculation: Lookback delta percentage = lookback delta divided by total chart-bar volume in the lookback window, multiplied by 100; use zero when total volume is zero.
Calculation: Session delta = sum of chart-bar volume for bars with close > open minus sum of chart-bar volume for bars with close < open, from the most recent selected daily or trading-session boundary through the current bar; unchanged bars contribute zero. If no boundary is found within the maximum search lookback, use the maximum lookback plus the boundary bar. Previous session delta uses the same window excluding the current bar.
Long: Intrabar delta >= 0
Short: Intrabar delta < 0
Long: Lookback delta >= 0
Short: Lookback delta < 0
Long: Intrabar delta percentage > positive threshold AND lookback delta percentage < negative threshold
Short: Intrabar delta percentage < negative threshold AND lookback delta percentage > positive threshold
Long: Session delta >= 0
Short: Session delta < 0
Long: Session delta > 0 AND previous session delta <= 0
Short: Session delta < 0 AND previous session delta >= 0
Long: Session delta > previous session delta AND NOT (session delta > 0 AND previous session delta <= 0) AND NOT (session delta < 0 AND previous session delta >= 0) AND absolute session delta >= absolute previous session delta multiplied by a thinning factor below one
Short: Session delta < previous session delta AND NOT (session delta > 0 AND previous session delta <= 0) AND NOT (session delta < 0 AND previous session delta >= 0) AND absolute session delta >= absolute previous session delta multiplied by a thinning factor below one