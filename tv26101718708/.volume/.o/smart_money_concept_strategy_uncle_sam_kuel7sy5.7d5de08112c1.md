Calculation: Confirmed swing high = a high greater than the highs of N bars before and N bars after it; confirm only after those N later bars are complete.
Calculation: Confirmed swing low = a low lower than the lows of N bars before and N bars after it; confirm only after those N later bars are complete.
Calculation: Selected moving average = the configured moving average of the configured source over the configured lookback.
Long: high > most recent confirmed swing high AND (MA filter disabled OR close > selected moving average)
Short: low < most recent confirmed swing low AND (MA filter disabled OR close < selected moving average)
Exit: long, low <= entry price × (1 − stop-loss percentage) OR high >= entry price × (1 + take-profit percentage)
Exit: short, high >= entry price × (1 + stop-loss percentage) OR low <= entry price × (1 − take-profit percentage)