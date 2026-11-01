Calculation: OsMA = short-period EMA of the selected OHLC-derived price minus long-period EMA of the same price, minus the simple moving average of that difference. Evaluate on the chart timeframe or on a higher or lower working timeframe, using either its last completed bar or its still-forming bar.
Long: OsMA < 0 AND OsMA > previous-bar OsMA AND previous-bar OsMA < 0 AND previous-bar OsMA < two-bars-ago OsMA
Short: OsMA > 0 AND OsMA < previous-bar OsMA AND previous-bar OsMA > 0 AND previous-bar OsMA > two-bars-ago OsMA
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance
Exit: long, opposite-position closing enabled AND short-entry condition AND time-of-day filter satisfied
Exit: short, opposite-position closing enabled AND long-entry condition AND time-of-day filter satisfied