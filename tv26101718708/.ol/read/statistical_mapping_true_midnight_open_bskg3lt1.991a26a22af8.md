Calculation: Distribution distance = mean or median of completed mapping bars’ (high − open) when close > open, and (open − low) when close < open.
Calculation: Manipulation distance = mean or median of completed mapping bars’ (open − low) when close > open, and (high − open) when close < open.
Calculation: Anchor open = open of the current mapping period, or the New York midnight open for daily mapping.
Calculation: +M = anchor open − manipulation distance.
Calculation: −M = anchor open + manipulation distance.
Calculation: +D = anchor open + distribution distance.
Calculation: −D = anchor open − distribution distance.
Long: low <= +M.
Short: high >= −M.
Exit: Long, high >= anchor open OR high >= +D.
Exit: Short, low <= anchor open OR low <= −D.