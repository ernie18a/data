Calculation: All-time high = highest high from the first bar through the current bar
Calculation: 200-week SMA = simple moving average of close over 200 higher-timeframe weekly bars, using the last completed weekly bar
Calculation: 2-year SMA = simple moving average of close over 730 higher-timeframe daily bars, using the last completed daily bar
Calculation: 200-day SMA = simple moving average of close over 200 higher-timeframe daily bars, using the last completed daily bar
Calculation: Weekly RSI = 14-bar RSI of close on the higher timeframe, using the last completed weekly bar
Calculation: Drawdown from all-time high = (all-time high − close) / all-time high
Calculation: Moving-average score = average of the available scores for close / 200-week SMA, close / 2-year SMA, and close / 200-day SMA; each ratio is linearly mapped from its expensive anchor to its deep-value anchor onto 0–100 and capped to that range
Calculation: Drawdown score = drawdown from all-time high linearly mapped from its expensive anchor to its deep-value anchor onto 0–100 and capped to that range
Calculation: Weekly RSI score = weekly RSI linearly mapped from its expensive anchor to its deep-value anchor onto 0–100 and capped to that range
Calculation: Composite = weighted average of the available moving-average, drawdown, and weekly RSI scores, renormalizing weights over available scores
Calculation: Capitulation eligibility = drawdown from all-time high meets or exceeds its threshold
Calculation: Deep-value eligibility = capitulation eligibility OR close / 200-week SMA is at or below its threshold
Calculation: Overheating signs = count of conditions met: close / 200-week SMA ≥ its threshold; weekly RSI ≥ its threshold; close / 200-day SMA ≥ its threshold
Calculation: Euphoria eligibility = overheating signs ≥ 1
Calculation: Cycle-top eligibility = overheating signs ≥ 2
Long: Composite crosses above the accumulation threshold
Long: Composite crosses above the deep-accumulation threshold AND deep-value eligibility
Long: Composite crosses above the generational-value threshold AND capitulation eligibility
Short: Composite crosses below the trim threshold
Short: Composite crosses below the euphoria threshold AND euphoria eligibility
Short: Composite crosses below the euphoria threshold AND cycle-top eligibility
Exit: Long, composite crosses below the euphoria threshold AND cycle-top eligibility