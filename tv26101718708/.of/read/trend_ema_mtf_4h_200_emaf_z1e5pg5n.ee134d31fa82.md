Calculation: Trend EMA = EMA of close on bars aggregated to a timeframe higher than the chart timeframe, using the last completed bar
Calculation: Trend direction = rising when the Trend EMA is greater than its prior value; falling when it is less; otherwise retain the prior direction, initially rising
Long: close >= Trend EMA AND Trend direction is rising
Short: close < Trend EMA AND Trend direction is falling