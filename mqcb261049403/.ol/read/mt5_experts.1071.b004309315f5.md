Calculation: BBSqueeze linear regression value = on the indicator timeframe (which may be higher, lower, or equal to the chart timeframe), for each of the latest N bars x = 0…N−1, calculate dₓ = closeₓ − ((highest high from x through x+N−1 bars ago + lowest low over that same window) / 2 + smoothed applied priceₓ) / 2; fit a least-squares linear regression of dₓ against x and take its value at x = N−1. Use completed indicator bars.
Long: latest completed bar’s BBSqueeze linear regression value ≥ 0 AND preceding completed bar’s value < 0
Short: latest completed bar’s BBSqueeze linear regression value < 0 AND preceding completed bar’s value ≥ 0
Exit: long, latest completed bar’s BBSqueeze linear regression value < 0
Exit: short, latest completed bar’s BBSqueeze linear regression value ≥ 0