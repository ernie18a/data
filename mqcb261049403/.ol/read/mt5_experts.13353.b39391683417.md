Calculation: Color Zero Lag X10 moving average = smooth the weighted sum of ten moving averages of a selected bar price, using progressively longer lookbacks; use the configured averaging method for each stage. Evaluate it on higher-timeframe bars aggregated from the chart bars, using completed bars.
Long: the value two completed signal-timeframe bars ago is lower than the value three bars ago AND the latest completed value is higher than the value two bars ago
Short: the value two completed signal-timeframe bars ago is higher than the value three bars ago AND the latest completed value is lower than the value two bars ago
Exit: long, the latest completed value is lower than the value one bar before it
Exit: short, the latest completed value is higher than the value one bar before it