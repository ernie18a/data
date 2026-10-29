Calculation: XDPO histogram = smooth the selected bar price with a first smoother, subtract that smoother from the selected price, then smooth the difference with a second smoother; use completed bars of the indicator timeframe, which may be higher or lower than the chart timeframe
Long: the histogram two bars ago is greater than the histogram one bar ago AND the latest completed histogram is greater than the histogram one bar ago
Short: the histogram two bars ago is less than the histogram one bar ago AND the latest completed histogram is less than the histogram one bar ago
Exit: long, the histogram one bar ago is greater than the latest completed histogram
Exit: short, the histogram one bar ago is less than the latest completed histogram