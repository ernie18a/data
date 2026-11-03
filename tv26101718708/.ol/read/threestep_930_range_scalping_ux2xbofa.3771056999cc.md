Calculation: Opening range high/low = high/low of the higher-timeframe bar that starts at 9:30, available only after that bar closes.
Calculation: Bullish fair value gap = current low and preceding bar low are both greater than the high two bars earlier.
Calculation: Bearish fair value gap = current high and preceding bar high are both less than the low two bars earlier.
Calculation: Upward break recorded = during the trading window, the first close above the opening range high has occurred.
Calculation: Downward break recorded = during the trading window, the first close below the opening range low has occurred.
Calculation: Upward retest recorded = after an upward break, a close at or between the opening range bounds has occurred.
Calculation: Downward retest recorded = after a downward break, a close at or between the opening range bounds has occurred.
Calculation: Break long stop = low of the earliest of the three fair value gap bars whose close is above the opening range high.
Calculation: Break short stop = high of the earliest of the three fair value gap bars whose close is below the opening range low.
Calculation: Trap long stop = low of the first bar that closed above the opening range high.
Calculation: Trap short stop = high of the first bar that closed below the opening range low.
Calculation: Reversal long stop = low two bars earlier.
Calculation: Reversal short stop = high two bars earlier.
Long: opening range is available AND time is 9:30–10:29 AND date is outside Dec 15–Jan 15 AND no position is open AND ((bullish fair value gap AND any of its three bars closes above the opening range high AND close > break long stop) OR (upward break recorded AND upward retest recorded AND close > opening range high AND close > trap long stop) OR (downward break recorded AND bullish fair value gap AND close is at or between opening range bounds AND close > reversal long stop))
Short: opening range is available AND time is 9:30–10:29 AND date is outside Dec 15–Jan 15 AND no position is open AND ((bearish fair value gap AND any of its three bars closes below the opening range low AND close < break short stop) OR (downward break recorded AND downward retest recorded AND close < opening range low AND close < trap short stop) OR (upward break recorded AND bearish fair value gap AND close is at or between opening range bounds AND close < reversal short stop))
Exit: long, low <= the stop recorded for the entry OR high >= entry price + reward-to-risk multiple × (entry price − that stop)
Exit: short, high >= the stop recorded for the entry OR low <= entry price − reward-to-risk multiple × (that stop − entry price)