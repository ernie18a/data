Calculation: Bull volume MA = selected moving average of volume when close > open, otherwise 0; moving-average type and lookback are parameters
Calculation: Bear volume MA = selected moving average of volume when open > close, otherwise 0; use the same moving-average type and lookback as the bull volume MA
Calculation: Close ROC = 100 × (close − close from the ROC lookback bars ago) / close from the ROC lookback bars ago
Calculation: Smoothed ROC = EMA of close ROC with a lookback half the ROC lookback
Calculation: Long condition time = current bar time when bull volume MA > bear volume MA and (smoothed ROC > half the movement threshold or smoothed ROC < negative half the movement threshold); otherwise retain its previous value
Calculation: Short condition time = current bar time when bear volume MA > bull volume MA and (smoothed ROC > half the movement threshold or smoothed ROC < negative half the movement threshold); otherwise retain its previous value
Long: Bull volume MA > bear volume MA AND (smoothed ROC > half the movement threshold OR smoothed ROC < negative half the movement threshold)
Long: Long condition time crosses above short condition time
Short: Bear volume MA > bull volume MA AND (smoothed ROC > half the movement threshold OR smoothed ROC < negative half the movement threshold)
Short: Short condition time crosses above long condition time
Exit: long, long condition time > short condition time AND (low <= entry price × (1 − stop-loss fraction) OR high >= entry price × (1 + take-profit fraction)); enable this exit after the entry bar
Exit: short, short condition time > long condition time AND (high >= entry price × (1 + stop-loss fraction) OR low <= entry price × (1 − take-profit fraction)); enable this exit after the entry bar