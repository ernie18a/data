Calculation: Opening range high = maximum high of chart bars in each session's initial range-duration window
Calculation: Opening range low = minimum low of chart bars in each session's initial range-duration window
Calculation: Opening range width = Opening range high - Opening range low
Long: first chart bar after the initial range window in each session with high > Opening range high
Short: first chart bar after the initial range window in each session with low < Opening range low
Exit: long, after an upward opening-range break in the current session, first chart bar with high >= Opening range high + target extension multiple × Opening range width
Exit: short, after a downward opening-range break in the current session, first chart bar with low <= Opening range low - target extension multiple × Opening range width