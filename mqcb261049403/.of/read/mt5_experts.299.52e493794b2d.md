Calculation: Bar index i = chart bar i bars before the currently forming bar; bar 1 is the last completed bar.
Calculation: Average body at i = simple average of abs(open − close) over the selected lookback ending at bar i; use the same lookback as the close simple moving average.
Calculation: Range midpoint at i = (high[i] + low[i]) / 2.
Calculation: Body midpoint at i = (open[i] + close[i]) / 2.
Long: close[3] − open[3] > average body at 1 AND close[2] − open[2] > average body at 1 AND close[1] − open[1] > average body at 1 AND range midpoint at 2 > range midpoint at 3 AND range midpoint at 1 > range midpoint at 2.
Long: close[1] − open[1] > average body at 1 AND open[2] − close[2] > average body at 1 AND close[2] > close[1] AND close[1] < open[2] AND body midpoint at 2 < close simple moving average at 2 AND open[1] < low[2].
Long: open[3] − close[3] > average body at 1 AND average body at 2 < average body at 1 multiplied by a small fraction AND close[2] < close[3] AND open[2] < open[3] AND open[1] > close[2] AND close[1] > close[2].
Long: open[2] > close[2] AND close[1] − open[1] > average body at 1 AND close[1] > open[2] AND body midpoint at 2 < close simple moving average at 2 AND open[1] < close[2].
Long: open[3] − close[3] > average body at 1 AND abs(close[2] − open[2]) < average body at 1 multiplied by a fraction greater than the doji fraction AND close[2] < close[3] AND open[2] < open[3] AND close[1] > body midpoint at 3.
Long: range midpoint at 1 < close simple moving average at 2 AND min(open[1], close[1]) > high[1] − (high[1] − low[1]) multiplied by a fraction AND close[1] < close[2] AND open[1] < open[2].
Long: close[1] > open[1] AND open[2] − close[2] > average body at 1 AND close[1] < open[2] AND open[1] > close[2] AND range midpoint at 2 < close simple moving average at 2.
Long: open[2] − close[2] > average body at 1 AND close[1] − open[1] > average body at 1 AND abs(close[1] − close[2]) < average body at 1 multiplied by the doji fraction.
Long: close[1] − open[1] > average body at 1 AND open[2] − close[2] > average body at 1 AND close[1] > close[2] AND close[1] < open[2] AND body midpoint at 2 < close simple moving average at 2 AND open[1] < low[2] AND money flow index at 1 < lower entry threshold.
Short: open[3] − close[3] > average body at 1 AND open[2] − close[2] > average body at 1 AND open[1] − close[1] > average body at 1 AND range midpoint at 2 < range midpoint at 3 AND range midpoint at 1 < range midpoint at 2.
Short: close[2] − open[2] > average body at 1 AND close[1] < close[2] AND close[1] > open[2] AND body midpoint at 2 > close simple moving average at 1 AND open[1] > high[2].
Short: close[3] − open[3] > average body at 1 AND average body at 2 < average body at 1 multiplied by the doji fraction AND close[2] > close[3] AND open[2] > open[3] AND open[1] < close[2] AND close[1] < close[2].
Short: open[2] < close[2] AND open[1] − close[1] > average body at 1 AND close[1] < open[2] AND body midpoint at 2 > close simple moving average at 2 AND open[1] > close[2].
Short: close[3] − open[3] > average body at 1 AND abs(close[2] − open[2]) < average body at 1 multiplied by the star fraction AND close[2] > close[3] AND open[2] > open[3] AND close[1] < body midpoint at 3.
Short: range midpoint at 1 > close simple moving average at 2 AND min(open[1], numeric value of (close[1] > high[1] − (high[1] − low[1]) multiplied by the hammer fraction)) != 0 AND close[1] > close[2] AND open[1] > open[2].
Short: close[1] < open[1] AND close[2] − open[2] > average body at 1 AND close[1] > open[2] AND open[1] < close[2] AND range midpoint at 2 > close simple moving average at 2.
Short: close[2] − open[2] > average body at 1 AND open[1] − close[1] > average body at 1 AND abs(close[1] − close[2]) < average body at 1 multiplied by the doji fraction.
Short: close[2] − open[2] > average body at 1 AND close[1] < close[2] AND close[1] > open[2] AND body midpoint at 2 > close simple moving average at 1 AND open[1] > high[2] AND money flow index at 1 > upper entry threshold.
Exit: short, (money flow index at 2 < lower exit threshold AND money flow index at 1 > lower exit threshold) OR (money flow index at 2 < upper exit threshold AND money flow index at 1 > upper exit threshold).
Exit: long, (money flow index at 2 < upper exit threshold AND money flow index at 1 > upper exit threshold) OR (money flow index at 2 > lower exit threshold AND money flow index at 1 < lower exit threshold).
Exit: long, low <= entry price − stop distance OR high >= entry price + profit distance.
Exit: short, high >= entry price + stop distance OR low <= entry price − profit distance.