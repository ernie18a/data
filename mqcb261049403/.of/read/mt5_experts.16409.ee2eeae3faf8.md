Calculation: Trend value = (shorter-period T3 moving average of close − longer-period T3 moving average of close) × Jurik moving average of close, calculated on a higher timeframe using the last completed bar or, if configured, the still-forming bar.
Long: Trend value >= previous trend value
Short: Trend value < previous trend value
Long: Direction mode = trend-following AND trend value >= previous trend value AND previous trend value < trend value two bars ago
Short: Direction mode = trend-following AND trend value < previous trend value AND previous trend value >= trend value two bars ago
Long: Direction mode = countertrend AND trend value < previous trend value AND previous trend value >= trend value two bars ago
Short: Direction mode = countertrend AND trend value >= previous trend value AND previous trend value < trend value two bars ago
Exit: long, direction mode = trend-following AND trend value < previous trend value OR direction mode = countertrend AND trend value >= previous trend value OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance
Exit: short, direction mode = trend-following AND trend value >= previous trend value OR direction mode = countertrend AND trend value < previous trend value OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance