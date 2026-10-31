Calculation: Range bands = a longer-period simple moving average of close plus or minus a shorter-period Jurik moving average of high minus low. Calculate both on a configurable higher or lower timeframe, using the last completed bar or, if configured, the bar still forming; compare each bar with its own band.
Long: Signal-bar close > upper range band AND preceding bar close <= its upper range band.
Short: Signal-bar close < lower range band AND preceding bar close >= its lower range band.
Exit: long, signal-bar close < lower range band OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, signal-bar close > upper range band OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.