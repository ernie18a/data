Calculation: Chart channel = highest high and lowest low over the same lookback, including the current chart bar; its midpoint is their average.
Calculation: Higher-timeframe channel = highest high and lowest low over the same number of bars as the chart channel, using the last completed higher-timeframe bar; its midpoint is their average.
Calculation: Long bias = chart channel lower bound > higher-timeframe channel midpoint AND datetime within the configured trading window.
Calculation: Short bias = chart channel upper bound < higher-timeframe channel midpoint AND datetime within the configured trading window.
Calculation: Long profit target = chart channel upper bound + risk-reward parameter × chart channel width while not long; while long, retain the previous target, adding risk-reward parameter × current chart channel width if the previous high > previous target.
Calculation: Short profit target = chart channel lower bound − risk-reward parameter × chart channel width while not short; while short, retain the previous target, subtracting risk-reward parameter × current chart channel width if the previous low < previous target.
Long: Long bias AND entry type = market AND high crosses above the previous chart bar's channel upper bound.
Long: Long bias AND entry type = stop AND high reaches the submitted chart channel upper bound.
Long: Long bias AND entry type = limit AND high > chart channel midpoint AND low reaches the submitted chart channel upper bound.
Long: Long bias AND entry type = stop-limit AND high crosses above the previous chart bar's channel upper bound AND high reaches the submitted chart channel upper bound AND low reaches the submitted upper bound plus a configured multiple of moving-average true range.
Short: Short bias AND entry type = market AND low crosses below the previous chart bar's channel lower bound.
Short: Short bias AND entry type = stop AND low reaches the submitted chart channel lower bound.
Short: Short bias AND entry type = limit AND low < chart channel midpoint AND high reaches the submitted chart channel lower bound.
Short: Short bias AND entry type = stop-limit AND low crosses below the previous chart bar's channel lower bound AND low reaches the submitted chart channel lower bound AND high reaches the submitted lower bound minus a configured multiple of moving-average true range.
Exit: long, short bias.
Exit: short, long bias.
Exit: long, exit type = market AND long bias is false AND low crosses below the previous chart bar's channel lower bound.
Exit: short, exit type = market AND short bias is false AND high crosses above the previous chart bar's channel upper bound.
Exit: long, exit type = stop AND low reaches the submitted chart channel lower bound.
Exit: short, exit type = stop AND high reaches the submitted chart channel upper bound.
Exit: long, take profit enabled AND long bias AND high reaches the submitted long profit target; exit the configured fraction of the position.
Exit: short, take profit enabled AND short bias AND low reaches the submitted short profit target; exit the configured fraction of the position.