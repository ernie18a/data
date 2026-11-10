Calculation: Lower-timeframe tape = the most recent positive-volume lower-timeframe bars, including the bar still forming. Classify each bar by comparing its close with the close of the preceding retained bar: positive if higher, negative if lower, and otherwise retain the preceding classification; initialize the classification to zero.
Calculation: Up volume and down volume = sum the volumes of the tape bars except its two oldest bars; assign positive-classified volume to up volume and all other volume to down volume.
Calculation: Lower-timeframe volume delta = sum positive-classified tape volume minus negative-classified tape volume; zero-classified volume contributes zero.
Calculation: Chart volume delta = volume times the absolute close-to-open body divided by high minus low, positive when close > open and negative otherwise; when high = low, use negative volume.
Calculation: Cumulative chart volume delta = the selected rolling sum, EMA, or SMA of chart volume delta.
Long: Up volume > down volume
Short: Down volume > up volume
Long: Cumulative chart volume delta > 0
Short: Cumulative chart volume delta < 0
Long: Cumulative chart volume delta > its previous chart-bar value
Short: Cumulative chart volume delta < its previous chart-bar value
Long: Lower-timeframe volume delta > 0
Short: Lower-timeframe volume delta < 0