Calculation: Relative volume = current volume / SMA of volume, including the current bar.
Long: Relative volume >= threshold AND close > open; alternatively, use close > previous close for the price comparison.
Short: Relative volume >= threshold AND close < open; alternatively, use close < previous close for the price comparison.
Long: Close > shorter EMA of close AND shorter EMA > longer EMA AND, if enabled, close > shorter SMA of close AND, if enabled, close > longer SMA of close AND, if enabled, longer EMA > its previous-bar value.
Long: Close > shorter SMA of close.
Short: Close <= shorter SMA of close.
Long: Close > longer SMA of close.
Short: Close <= longer SMA of close.