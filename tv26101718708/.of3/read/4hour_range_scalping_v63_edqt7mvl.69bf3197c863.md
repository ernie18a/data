Calculation: Opening range high = highest high of T1 chart bars in the opening window of each selected major trading day
Calculation: Opening range low = lowest low of T1 chart bars in the opening window of each selected major trading day
Calculation: Failed upside breakout peak = highest high of T1 bars whose close is above the opening range high during the breakout
Calculation: Failed downside breakout trough = lowest low of T1 bars whose close is below the opening range low during the breakout
Long: opening range is set AND a T1 bar has closed below the opening range low since it was set AND the current close crosses above the opening range low
Short: opening range is set AND a T1 bar has closed above the opening range high since it was set AND the current close crosses below the opening range high
Exit: long, low <= failed downside breakout trough OR high >= entry price + risk/reward ratio parameter × (entry price − failed downside breakout trough)
Exit: short, high >= failed upside breakout peak OR low <= entry price − risk/reward ratio parameter × (failed upside breakout peak − entry price)