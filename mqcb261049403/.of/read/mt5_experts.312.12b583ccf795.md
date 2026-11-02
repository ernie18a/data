Calculation: Bar index i = the i-th completed chart bar, with i=1 denoting the latest completed bar.
Calculation: Average body at i = the simple moving average of abs(open − close), ending at bar i; use the same lookback as the close SMA.
Calculation: Range midpoint at i = (high[i] + low[i]) / 2.
Calculation: Body midpoint at i = (open[i] + close[i]) / 2.
Long: close[3] − open[3] > average body at 1 AND close[2] − open[2] > average body at 1 AND close[1] − open[1] > average body at 1 AND range midpoint at 2 > range midpoint at 3 AND range midpoint at 1 > range midpoint at 2.
Long: close[1] − open[1] > average body at 1 AND open[2] − close[2] > average body at 1 AND close[2] > close[1] AND close[1] < open[2] AND body midpoint at 2 < close SMA at 2 AND open[1] < low[2].
Long: open[3] − close[3] > average body at 1 AND average body at 2 < average body at 1 × small-body fraction AND close[2] < close[3] AND open[2] < open[3] AND open[1] > close[2] AND close[1] > close[2].
Long: open[2] > close[2] AND close[1] − open[1] > average body at 1 AND close[1] > open[2] AND body midpoint at 2 < close SMA at 2 AND open[1] < close[2].
Long: open[3] − close[3] > average body at 1 AND abs(close[2] − open[2]) < average body at 1 × larger body fraction AND close[2] < close[3] AND open[2] < open[3] AND close[1] > body midpoint at 3.
Long: range midpoint at 1 < close SMA at 2 AND min(open[1], close[1]) > high[1] − (high[1] − low[1]) × upper-range fraction AND close[1] < close[2] AND open[1] < open[2].
Long: close[1] > open[1] AND open[2] − close[2] > average body at 1 AND close[1] < open[2] AND open[1] > close[2] AND range midpoint at 2 < close SMA at 2.
Long: open[2] − close[2] > average body at 1 AND close[1] − open[1] > average body at 1 AND abs(close[1] − close[2]) < average body at 1 × small-body fraction.
Short: open[3] − close[3] > average body at 1 AND open[2] − close[2] > average body at 1 AND open[1] − close[1] > average body at 1 AND range midpoint at 2 < range midpoint at 3 AND range midpoint at 1 < range midpoint at 2.
Short: close[2] − open[2] > average body at 1 AND close[1] < close[2] AND close[1] > open[2] AND body midpoint at 2 > close SMA at 1 AND open[1] > high[2].
Short: close[3] − open[3] > average body at 1 AND average body at 2 < average body at 1 × small-body fraction AND close[2] > close[3] AND open[2] > open[3] AND open[1] < close[2] AND close[1] < close[2].
Short: open[2] < close[2] AND open[1] − close[1] > average body at 1 AND close[1] < open[2] AND body midpoint at 2 > close SMA at 2 AND open[1] > close[2].
Short: close[3] − open[3] > average body at 1 AND abs(close[2] − open[2]) < average body at 1 × larger body fraction AND close[2] > close[3] AND open[2] > open[3] AND close[1] < body midpoint at 3.
Short: range midpoint at 1 > close SMA at 2 AND min(open[1], indicator(close[1] > high[1] − (high[1] − low[1]) × upper-range fraction) × indicator(close[1] > close[2]) × indicator(open[1] > open[2])) != 0, where indicator is 1 when its comparison is true and 0 otherwise.
Short: close[1] < open[1] AND close[2] − open[2] > average body at 1 AND close[1] > open[2] AND open[1] < close[2] AND range midpoint at 2 > close SMA at 2.
Short: close[2] − open[2] > average body at 1 AND open[1] − close[1] > average body at 1 AND abs(close[1] − close[2]) < average body at 1 × small-body fraction.
Long: close[1] > open[1] AND open[2] − close[2] > average body at 1 AND close[1] < open[2] AND open[1] > close[2] AND range midpoint at 2 < close SMA at 2 AND MFI[1] < long-entry threshold.
Short: close[1] < open[1] AND close[2] − open[2] > average body at 1 AND close[1] > open[2] AND open[1] < close[2] AND range midpoint at 2 > close SMA at 2 AND MFI[1] > short-entry threshold.
Exit: short, (MFI[1] > lower exit threshold AND MFI[2] < lower exit threshold) OR (MFI[1] > upper exit threshold AND MFI[2] < upper exit threshold).
Exit: long, (MFI[1] > upper exit threshold AND MFI[2] < upper exit threshold) OR (MFI[1] < lower exit threshold AND MFI[2] > lower exit threshold).