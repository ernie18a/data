Calculation: Short-period VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume over chart bars in the current, still-forming shorter higher-timeframe period.
Calculation: Long-period VWAP = cumulative sum of ((high + low + close) / 3 × volume) divided by cumulative volume over chart bars in the current, still-forming longer higher-timeframe period.
Calculation: Signal spacing = chart bars elapsed since the last long or short transition signal; initialize the last signal bar index to zero and update it on each transition signal.
Long: Close > EMA of close.
Short: Close < EMA of close.
Long: Close > open of the current, still-forming longer higher-timeframe period.
Short: Close < open of the current, still-forming longer higher-timeframe period.
Long: Close > long-period VWAP.
Short: Close < long-period VWAP.
Long: Short-period VWAP > open of the current, still-forming shorter higher-timeframe period.
Short: Short-period VWAP < open of the current, still-forming shorter higher-timeframe period.
Long: Close > short-period VWAP AND close > open of the current, still-forming shorter higher-timeframe period AND (previous close <= previous short-period VWAP OR previous close <= previous shorter-period open) AND signal spacing > the minimum spacing parameter.
Short: Close < short-period VWAP AND close < open of the current, still-forming shorter higher-timeframe period AND (previous close >= previous short-period VWAP OR previous close >= previous shorter-period open) AND signal spacing > the minimum spacing parameter.
Exit: long, low <= high of the last completed shorter higher-timeframe period AND high >= that high AND no earlier chart bar in the current shorter-period has touched that high.
Exit: short, low <= low of the last completed shorter higher-timeframe period AND high >= that low AND no earlier chart bar in the current shorter-period has touched that low.