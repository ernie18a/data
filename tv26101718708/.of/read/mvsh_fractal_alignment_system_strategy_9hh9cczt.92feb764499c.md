Calculation: Bullish three-bar fractal = the middle bar’s low is below the low of the bar before it, and the following bar’s low is above the middle bar’s low
Calculation: Bearish three-bar fractal = the middle bar’s high is above the high of the bar before it, and the following bar’s high is below the middle bar’s high
Calculation: Daily bias = direction of the most recently detected bullish or bearish three-bar fractal, calculated from the last completed bars of a timeframe higher than the chart timeframe; bullish if the latest is bullish, bearish if the latest is bearish, otherwise neutral
Calculation: Long initial stop = prior chart bar’s low minus a configurable buffer; short initial stop = prior chart bar’s high plus a configurable buffer
Calculation: Long targets = entry price plus initial risk distance multiplied by configurable first and second reward-to-risk ratios; short targets = entry price minus initial risk distance multiplied by those ratios
Long: bullish three-bar fractal AND session hour is within the configured session AND daily bias is bullish AND long entries today are below the configured daily limit AND position is flat
Short: bearish three-bar fractal AND session hour is within the configured session AND daily bias is bearish AND short entries today are below the configured daily limit AND position is flat
Exit: Long, before first target: low <= long initial stop OR high >= long first target
Exit: Long, after first target and before second target: low <= entry price OR high >= long second target
Exit: Long, after second target: low <= the greater of entry price and the highest high since the second target minus the configurable trailing distance
Exit: Short, before first target: high >= short initial stop OR low <= short first target
Exit: Short, after first target and before second target: high >= entry price OR low <= short second target
Exit: Short, after second target: high >= the lesser of entry price and the lowest low since the second target plus the configurable trailing distance