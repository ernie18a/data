Calculation: Failure-high signal = On chart bars at each new T1 period, using the last completed T1 bar [1] and preceding completed T1 bar [2]: high[1] > high[2] AND close[1] <= high[2] AND high[1] > max(open[1], close[1]) AND high[1] - low[1] >= minimum failure range parameter
Calculation: Failure-low signal = On chart bars at each new T1 period, using the last completed T1 bar [1] and preceding completed T1 bar [2]: low[1] < low[2] AND close[1] >= low[2] AND min(open[1], close[1]) > low[1] AND high[1] - low[1] >= minimum failure range parameter
Calculation: Inside-bar pattern = On chart bars at each new T1 period, using the last completed T1 bar [1] and preceding completed T1 bar [2]: high[1] < high[2] AND low[1] > low[2]
Long: Failure-low signal AND failure patterns enabled
Short: Failure-high signal AND failure patterns enabled
Long: flat AND entry time is at or after 6:00 PM ET or before 4:00 PM ET AND the latest enabled failure-high, failure-low, or inside-bar setup formed while flat outside 4:00–6:00 PM ET AND the first chart-TF close beyond either boundary during the immediately following T1 window is above the setup bar's high
Short: flat AND entry time is at or after 6:00 PM ET or before 4:00 PM ET AND the latest enabled failure-high, failure-low, or inside-bar setup formed while flat outside 4:00–6:00 PM ET AND the first chart-TF close beyond either boundary during the immediately following T1 window is below the setup bar's low
Exit: long, low <= setup bar's low OR high >= entry price + (entry price - setup bar's low) * R-multiple parameter
Exit: short, high >= setup bar's high OR low <= entry price - (setup bar's high - entry price) * R-multiple parameter
Exit: long, break-even mode enabled AND close-at-target mode disabled AND a chart-TF close since entry has had close profit >= profit-threshold parameter AND current chart-TF close <= entry price
Exit: short, break-even mode enabled AND close-at-target mode disabled AND a chart-TF close since entry has had close profit >= profit-threshold parameter AND current chart-TF close >= entry price
Exit: long, close-at-target mode enabled AND break-even mode disabled AND current chart-TF close profit >= profit-threshold parameter
Exit: short, close-at-target mode enabled AND break-even mode disabled AND current chart-TF close profit >= profit-threshold parameter
Exit: long, chart bar time is 4:09 PM ET
Exit: short, chart bar time is 4:09 PM ET