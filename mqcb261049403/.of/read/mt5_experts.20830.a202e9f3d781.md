Calculation: Normalized range oscillator = 100 × moving average of (close − low) / max(moving average of true range, minimum price increment); the two moving averages have independently selectable methods and lookbacks.
Long: Chart-timeframe oscillator > middle threshold.
Short: Chart-timeframe oscillator < middle threshold.
Long: Oscillator on a selectable higher or lower timeframe, using the last completed bar or the bar still forming, > upper threshold AND its preceding bar's oscillator <= upper threshold.
Short: Oscillator on a selectable higher or lower timeframe, using the last completed bar or the bar still forming, < lower threshold AND its preceding bar's oscillator >= lower threshold.
Exit: long, oscillator on the selected higher or lower timeframe, using the last completed bar or the bar still forming, < lower threshold OR low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, oscillator on the selected higher or lower timeframe, using the last completed bar or the bar still forming, > upper threshold OR high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.