Calculation: Gap top and bottom = at each selected gap-period boundary, the maximum and minimum, respectively, of the previous completed chart bar’s close and the current chart bar’s open.
Calculation: Swing point = while eligible to trade and the chart bar’s range overlaps the gap, initialize to the bar’s low if close > gap top, otherwise to its high; on each further overlapping bar, update to the minimum of the prior swing point and bar low if close > gap top, otherwise to the maximum of the prior swing point and bar high. Reset outside an enabled session or after entry.
Calculation: Stop price = swing point minus the configured tick offset for a long, or plus it for a short.
Long: no trade taken today AND position is flat AND current time is in an enabled session AND gap exists AND swing point is defined AND close > gap top AND previous chart bar low <= gap top.
Short: no trade taken today AND position is flat AND current time is in an enabled session AND gap exists AND swing point is defined AND close < gap bottom AND previous chart bar high >= gap bottom.
Exit: long, bar low <= stop price
Exit: short, bar high >= stop price