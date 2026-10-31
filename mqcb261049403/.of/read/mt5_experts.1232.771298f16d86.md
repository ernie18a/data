Calculation: Regression line = fit a least-squares line to the latest lookback of a moving average of the selected price; evaluate the line at the bar a configurable lag before the newest bar in that lookback. The moving-average period equals the regression lookback.
Calculation: Trigger line = twice the current regression line minus the regression line a configurable number of bars earlier; this lag equals the regression evaluation lag.
Calculation: Signal values = regression line and trigger line calculated on a higher timeframe, using either the last completed bar or the still-forming bar, as configured; previous values use the preceding higher-timeframe bar.
Long: Trigger line > regression line AND previous trigger line <= previous regression line
Short: Trigger line < regression line AND previous trigger line >= previous regression line
Exit: long, trigger line < regression line OR low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, trigger line > regression line OR high >= entry price + stop-loss distance OR low <= entry price - take-profit distance