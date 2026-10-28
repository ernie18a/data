Calculation: Delta = (close > open ? volume : volume / 2) - (close < open ? volume : volume / 2)
Calculation: Cumulative volume delta = cumulative sum of Delta
Long: current Delta > 0 AND previous-bar Delta <= 0 AND Cumulative volume delta > its simple moving average
Short: current Delta < 0 AND previous-bar Delta >= 0 AND Cumulative volume delta < its simple moving average