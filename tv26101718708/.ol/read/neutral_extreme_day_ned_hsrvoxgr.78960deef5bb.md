Calculation: first-two-bar high = highest high of the first two bars of each day
Calculation: first-two-bar low = lowest low of the first two bars of each day
Calculation: VWAP = cumulative volume-weighted average of (high + low + close) / 3 since the start of the current day
Long: after the first two bars of the day, a bar's low has been below the first-two-bar low AND close > VWAP AND no long or short signal has already triggered that day
Short: after the first two bars of the day, a bar's high has been above the first-two-bar high AND close < VWAP AND no long or short signal has already triggered that day