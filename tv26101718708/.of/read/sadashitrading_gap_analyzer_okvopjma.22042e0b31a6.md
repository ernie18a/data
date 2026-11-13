Calculation: GapPct = (current bar open - previous bar close) / previous bar close * 100
Calculation: RVOL = current bar volume / simple moving average of volume over the lookback bars before the current bar (current bar excluded)
Long: GapPct >= minimum gap threshold AND RVOL >= minimum RVOL threshold (the position is entered at the open of this bar; a gap-up above or below the previous bar's simple moving average of close is a long either way)
Short: GapPct <= -minimum gap threshold AND RVOL >= minimum RVOL threshold (the position is entered at the open of this bar; a gap-down above or below the previous bar's simple moving average of close is a short either way)
Exit: long, bars elapsed since the long entry bar == fixed holding length (0 = the entry bar itself), exit at the close of that bar
Exit: short, bars elapsed since the short entry bar == fixed holding length (0 = the entry bar itself), exit at the close of that bar