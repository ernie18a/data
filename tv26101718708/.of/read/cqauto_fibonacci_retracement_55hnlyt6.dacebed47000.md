Calculation: Pivot high = high floor(depth/2) bars ago is >= the highest high in the current depth-bar window
Calculation: Pivot low = low floor(depth/2) bars ago is <= the lowest low in the current depth-bar window
Calculation: Pivot deviation = 100 * (candidate pivot price - previous pivot price) / candidate pivot price
Calculation: Pivot confirmation threshold = ATR(20) / close * wave-size
Long: latest confirmed pivot is a low
Short: latest confirmed pivot is a high