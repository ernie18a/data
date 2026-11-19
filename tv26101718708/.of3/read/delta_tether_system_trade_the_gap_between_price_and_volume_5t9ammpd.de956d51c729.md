Calculation: Delta line = if smoothing is enabled, EMA(LinearRegression(close, delta lookback, zero offset), smoothing lookback) when EMA smoothing is selected, otherwise SMA(LinearRegression(close, delta lookback, zero offset), smoothing lookback); otherwise LinearRegression(close, delta lookback, zero offset)
Calculation: Average true range = ATR(ATR lookback)
Calculation: Tether = (close - delta line) / average true range
Calculation: Tether rank = PercentRank(abs(tether), rank lookback)
Calculation: Trend average = EMA(close, trend lookback)
Calculation: Volume average = SMA(volume, volume lookback)
Calculation: Initial long stop = on the signal bar, delta line - (rung multiple + ATR buffer) * average true range in Mean Reversion mode, or delta line - ATR buffer * average true range in Trend Following mode
Calculation: Initial short stop = on the signal bar, delta line + (rung multiple + ATR buffer) * average true range in Mean Reversion mode, or delta line + ATR buffer * average true range in Trend Following mode
Calculation: Long stop = initial long stop; when trailing is enabled and close - position entry price >= trailing activation multiple * average true range, update to max(previous long stop, delta line)
Calculation: Short stop = initial short stop; when trailing is enabled and position entry price - close >= trailing activation multiple * average true range, update to min(previous short stop, delta line)
Calculation: Long target = signal bar close + (signal bar close - initial long stop) * the reward multiple for the entry mode
Calculation: Short target = signal bar close - (initial short stop - signal bar close) * the reward multiple for the entry mode
Long: Tether >= 0
Short: Tether < 0
Long: extremity markers are enabled AND Tether rank >= warning rank threshold for at least the warning consecutive-bar count consecutive bars AND Tether < 0
Short: extremity markers are enabled AND Tether rank >= warning rank threshold for at least the warning consecutive-bar count consecutive bars AND Tether > 0
Long: position is flat AND bar is confirmed AND (volume filter is disabled OR volume > volume average * volume surge multiplier) AND (rank cooldown is disabled OR no long entry has occurred since Tether rank last fell below the cooldown reset threshold) AND ((Mean Reversion mode AND Tether < 0 AND Tether rank >= Mean Reversion rank threshold AND Tether rank < Tether rank[1] AND (trend filter is disabled OR close < trend average)) OR (Trend Following mode AND Tether crosses above 0 AND Tether rank < Trend Following rank threshold AND (trend filter is disabled OR close > trend average)))
Short: position is flat AND bar is confirmed AND (volume filter is disabled OR volume > volume average * volume surge multiplier) AND (rank cooldown is disabled OR no short entry has occurred since Tether rank last fell below the cooldown reset threshold) AND ((Mean Reversion mode AND Tether > 0 AND Tether rank >= Mean Reversion rank threshold AND Tether rank < Tether rank[1] AND (trend filter is disabled OR close > trend average)) OR (Trend Following mode AND Tether crosses below 0 AND Tether rank < Trend Following rank threshold AND (trend filter is disabled OR close < trend average)))
Exit: Long, (bar is confirmed AND ((Mean Reversion mode AND Tether crosses above 0) OR (Trend Following mode AND Tether crosses below 0))) OR low <= long stop OR high >= long target
Exit: Short, (bar is confirmed AND ((Mean Reversion mode AND Tether crosses below 0) OR (Trend Following mode AND Tether crosses above 0))) OR high >= short stop OR low <= short target