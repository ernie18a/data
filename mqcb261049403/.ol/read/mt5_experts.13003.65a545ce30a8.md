Calculation: Tick volume index = let up = (volume + (close - open) / price increment) / 2 and down = volume - up; smooth up and down separately twice in succession using the same moving-average method and two independently parameterized lengths, shared between up and down; then smooth 100 × (smoothed up - smoothed down) / (smoothed up + smoothed down) with the same method and a third independently parameterized length.
Calculation: Signal index = tick volume index on a higher timeframe, evaluated on the last completed bar or the still-forming bar according to the signal-bar setting; prior values are from preceding bars of that timeframe.
Long: chart-timeframe tick volume index > 0 AND chart-timeframe tick volume index != its previous value
Short: chart-timeframe tick volume index < 0 AND chart-timeframe tick volume index != its previous value
Long: signal index > its previous value AND its value two bars ago > its previous value
Short: signal index < its previous value AND its value two bars ago < its previous value
Exit: short, signal index > its previous value
Exit: long, signal index < its previous value
Exit: long, low <= entry price - stop-loss distance OR high >= entry price + take-profit distance
Exit: short, high >= entry price + stop-loss distance OR low <= entry price - take-profit distance