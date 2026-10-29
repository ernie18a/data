Calculation: Pivot low = minimum of the current and previous chart-bar lows, updated when a bullish bar (close > open) follows a bearish bar (close < open); otherwise retain the latest value
Calculation: Pivot high = maximum of the current and previous chart-bar highs, updated when a bearish bar follows a bullish bar; otherwise retain the latest value
Calculation: Regular range = high and low of the preceding completed higher-timeframe bar when the latest completed higher-timeframe bar closes within its range at the start of a new higher-timeframe bar; alternatively, high and low of the preceding session when its close is within its range at the start of a new session
Calculation: Pending bearish level = latest pivot low when an unmitigated range high is first touched or exceeded; replace the prior bearish level on a new trigger, and update it to the latest pivot low below the mitigated range high when a bar's high and low straddle that high
Calculation: Pending bullish level = latest pivot high when an unmitigated range low is first touched or crossed; replace the prior bullish level on a new trigger, and update it to the latest pivot high above the mitigated range low when a bar's high and low straddle that low
Calculation: Long stop = current pivot low at long confirmation; long target = entry price + (entry price - long stop) × risk/reward ratio
Calculation: Short stop = current pivot high at short confirmation; short target = entry price - (short stop - entry price) × risk/reward ratio
Long: close > pending bullish level
Short: close < pending bearish level
Exit: Long, low <= long stop OR (take profit enabled AND high >= long target) OR close < pending bearish level
Exit: Short, high >= short stop OR (take profit enabled AND low <= short target) OR close > pending bullish level