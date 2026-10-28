Calculation: Delta = volume if close > open, −volume if close < open, otherwise 0
Calculation: Latest confirmed 30m pivot high = pivot high of aggregated 30m highs using left and right pivot lookbacks
Calculation: Latest confirmed 30m pivot low = pivot low of aggregated 30m lows using left and right pivot lookbacks
Long: Latest confirmed 30m pivot high and low exist AND latest confirmed 30m pivot high − latest confirmed 30m pivot low ≥ minimum pivot range AND close > latest confirmed 30m pivot low AND Delta < 0
Short: Latest confirmed 30m pivot high and low exist AND latest confirmed 30m pivot high − latest confirmed 30m pivot low ≥ minimum pivot range AND close < latest confirmed 30m pivot high AND Delta > 0
Exit: long, consecutive bars in long position ≥ exit-bar threshold
Exit: short, consecutive bars in short position ≥ exit-bar threshold