Calculation: Custom MFI = 100 × positive flow / (positive flow + negative flow), where positive and negative flow are rolling sums over the same lookback of volume × HLC3 on rising and falling HLC3 bars, respectively
Calculation: Rate-of-change filter = EMA of close percentage change over the ROC lookback, using half that lookback as the EMA length
Calculation: Moving-market condition = rate-of-change filter > half the threshold OR rate-of-change filter < negative half the threshold
Calculation: Gaussian filter = N-pole recursive Gaussian low-pass filter of HLC3, with alpha derived from the sampling period and pole count; optionally apply lag reduction using the sampling period and pole count, and optionally average the N-pole output with the one-pole output
Long: Gaussian filter > its previous-bar value AND moving-market condition AND custom MFI > its previous-bar value
Short: Gaussian filter < its previous-bar value AND moving-market condition AND custom MFI < its previous-bar value
Exit: long, after the entry bar, low <= entry price × (1 − stop-loss %) OR high >= entry price × (1 + take-profit %)
Exit: short, after the entry bar, high >= entry price × (1 + stop-loss %) OR low <= entry price × (1 − take-profit %)