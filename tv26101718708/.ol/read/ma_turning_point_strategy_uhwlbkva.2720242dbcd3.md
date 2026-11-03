Calculation: Selected MA = user-selected SMA, EMA, HMA, VWMA, or linear-regression MA of the selected source
Calculation: ROC = percentage change in the selected MA over the lookback
Calculation: Direction state = up after ROC crosses above the positive slope threshold; down after ROC crosses below the negative slope threshold; otherwise retain the prior state (initially false)
Long: ROC crosses above the positive slope threshold AND the direction state on the previous bar was down
Short: ROC crosses below the negative slope threshold AND the direction state on the previous bar was up