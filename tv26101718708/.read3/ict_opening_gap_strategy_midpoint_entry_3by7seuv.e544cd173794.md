Calculation: gap upper = max(previous chart bar close, open of the first chart bar of each date), retained until the next date
Calculation: gap lower = min(previous chart bar close, open of the first chart bar of each date), retained until the next date
Calculation: gap midpoint = (gap upper + gap lower) / 2
Long: flat AND no entry condition triggered on an earlier chart bar of the current date AND at least one chart bar since the current date began has high > gap upper AND current low <= gap midpoint + long offset
Short: flat AND no entry condition triggered on an earlier chart bar of the current date AND at least one chart bar since the current date began has low < gap lower AND current high >= gap midpoint - short offset
Exit: long, highest high since entry >= entry price + trailing activation distance in ticks AND current low <= highest high since entry
Exit: short, lowest low since entry <= entry price - trailing activation distance in ticks AND current high >= lowest low since entry