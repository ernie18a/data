Calculation: advance-decline volume = advancing-volume close(T1, bar still forming, on chart bars) - declining-volume close(T1, bar still forming, on chart bars)
Calculation: normalized advance-decline change = (advance-decline volume - nz(advance-decline volume[1] on the previous chart bar, 0)) * 100 / (advancing-volume close(T1, bar still forming, on chart bars) + declining-volume close(T1, bar still forming, on chart bars))
Calculation: signal state = if normalized advance-decline change > upper threshold then long, else if normalized advance-decline change < lower threshold then short, else previous signal state (initially neutral)
Long: signal state = long
Short: signal state = short