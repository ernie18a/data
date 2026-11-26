Long: on chart bars, high >= high[1](T1, last completed bar)
Short: on chart bars, low <= low[1](T1, last completed bar)
Exit: long, (stop-loss points > 0 AND low <= entry price - stop-loss points × point size) OR (take-profit points > 0 AND high >= entry price + take-profit points × point size)
Exit: short, (stop-loss points > 0 AND high >= entry price + stop-loss points × point size) OR (take-profit points > 0 AND low <= entry price - take-profit points × point size)