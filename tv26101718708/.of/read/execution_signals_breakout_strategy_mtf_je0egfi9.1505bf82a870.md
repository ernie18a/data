Calculation: Signal bar = last completed higher-timeframe bar; preceding signal bar = the higher-timeframe bar immediately before it.
Calculation: Failure high = signal bar high > preceding signal bar high AND signal bar close <= preceding signal bar high AND signal bar high > max(signal bar open, signal bar close) AND signal bar high - signal bar low >= minimum failure range.
Calculation: Failure low = signal bar low < preceding signal bar low AND signal bar close >= preceding signal bar low AND signal bar low < min(signal bar open, signal bar close) AND signal bar high - signal bar low >= minimum failure range.
Calculation: Inside bar = signal bar high < preceding signal bar high AND signal bar low > preceding signal bar low.
Calculation: Pending setup = a signal bar satisfying an enabled failure-high, failure-low, or inside-bar condition, detected while flat and outside the excluded session; it remains valid only during the immediately following higher-timeframe window, until an entry or the forced-close time, and a newer setup replaces it. Its upper and lower levels are the signal bar high and low.
Calculation: Favorable threshold reached = since entry, a chart-bar close has been at least the profit threshold above the long entry price or below the short entry price.
Long: Failure-low detection enabled AND failure low.
Short: Failure-high detection enabled AND failure high.
Long: Pending setup exists AND position is flat AND chart-bar time is outside the excluded session AND chart-bar close > pending setup upper level.
Short: Pending setup exists AND position is flat AND chart-bar time is outside the excluded session AND chart-bar close < pending setup lower level.
Exit: long, chart-bar low <= entry setup lower level OR chart-bar high >= entry price + target multiple * (entry price - entry setup lower level).
Exit: short, chart-bar high >= entry setup upper level OR chart-bar low <= entry price - target multiple * (entry setup upper level - entry price).
Exit: long, break-even mode enabled AND close-at-target mode disabled AND favorable threshold reached AND chart-bar close <= entry price.
Exit: short, break-even mode enabled AND close-at-target mode disabled AND favorable threshold reached AND chart-bar close >= entry price.
Exit: long OR short, close-at-target mode enabled AND break-even mode disabled AND favorable threshold reached.
Exit: long OR short, chart-bar opening time in New York equals the forced-close time.