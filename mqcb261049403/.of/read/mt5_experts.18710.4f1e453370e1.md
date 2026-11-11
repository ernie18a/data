Calculation: Down-bar count = number of bars with open > close in the lookback, including the still-forming bar, on a timeframe lower than or equal to the chart timeframe.
Calculation: Up-bar count = number of bars with open < close over the same lookback and timeframe, including the still-forming bar.
Long: Down-bar count > up-bar count AND current hour equals either of two specified hours with the same hour offset AND current minute < a specified limit.
Short: Down-bar count < up-bar count AND current hour equals either of two specified hours with the same hour offset AND current minute < a specified limit.
Exit: long, current price >= entry price OR price <= entry price minus the stop-loss distance OR price >= entry price plus the take-profit distance.
Exit: short, current price <= entry price OR price >= entry price plus the stop-loss distance OR price <= entry price minus the take-profit distance.